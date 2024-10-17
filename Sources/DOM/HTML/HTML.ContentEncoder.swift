extension HTML
{
    @frozen public
    struct ContentEncoder:StreamingEncoder
    {
        @usableFromInline
        var utf8:[UInt8]

        @inlinable
        init(utf8:[UInt8] = [])
        {
            self.utf8 = utf8
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable  static
    func += (self:inout Self, utf8:some Sequence<UInt8>)
    {
        for codeunit:UInt8 in utf8
        {
            self.append(unescaped: codeunit)
        }
    }
}
extension HTML.ContentEncoder:DOM.ContentEncoder
{
    @usableFromInline
    typealias AttributeEncoder = HTML.AttributeEncoder

    /// Appends a *raw* UTF-8 code unit to the output stream.
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.utf8.append(codeunit)
    }
}
public extension HTML.ContentEncoder
{
    /// Appends an *unescaped* UTF-8 code unit to the output stream.
    /// If the code unit is one of the ASCII characters `&` `<`, or `>`,
    /// this function replaces it with the corresponding HTML entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        self.utf8 += DOM.UTF8.init(codeunit)
    }
    /// Writes an opening HTML tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:) [8M0O5]``.
    @inlinable public mutating
    func open(_ tag:HTML.ContainerElement,
        with yield:(inout HTML.AttributeEncoder) -> () = { _ in })
    {
        self.emit(opening: tag, with: yield)
    }
    /// Writes a closing HTML tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:) [8M0O5]``.
    @inlinable public mutating
    func close(_ tag:HTML.ContainerElement)
    {
        self.emit(closing: tag)
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_ tag:HTML.ContainerElement,
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag)
            encode(&self)
            self.close(tag)
        }
    }

    @inlinable public
    subscript(_ tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag, with: attributes)
            encode(&self)
            self.close(tag)
        }
    }

    @inlinable public
    subscript(_ tag:HTML.VoidElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.emit(opening: tag, with: attributes)
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_ tag:HTML.UnsafeElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.emit(opening: tag, with: attributes)
            self.emit(closing: tag)
        }
    }
    /// Encodes an HTML element with unsafe content. The getter returns an empty string.
    @inlinable public
    subscript(unsafe tag:HTML.UnsafeElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> String
    {
        get { "" }
        set(unsafe)
        {
            self.emit(opening: tag, with: attributes)
            self.utf8 += unsafe.utf8
            self.emit(closing: tag)
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_:SVG.Embedded,
        attributes:(inout SVG.AttributeEncoder) -> (),
        content encode:(inout SVG.ContentEncoder) -> ()) -> Void
    {
        mutating get
        {
            {
                $0.open(.svg, with: attributes)
                encode(&$0)
                $0.close(.svg)
            } (&self[as: SVG.ContentEncoder.self])
        }
    }
}


extension HTML.ContentEncoder
{
    /// Encodes **any** ``HTML.OutputStreamable`` value to this HTML stream.
    ///
    /// This is the **only** supported interface for encoding existentials to HTML, since
    /// `Optional<any HTML.OutputStreamable>` would displace all of the DSL’s generic overloads.
    @inlinable public static
    func *= (html:inout Self, _self:any HTML.OutputStreamable)
    {
        _self.encode(to: &html)
    }
}
extension HTML.ContentEncoder
{
    /// Optionally encodes an ``HTML.OutputStreamable`` value to the stream through **multiple
    /// levels** of HTML tags, with optional attributes added to the **outermost** wrapper tag.
    ///
    /// If the value is nil, `attributes` will not be evaluated and nothing will be encoded.
    /// The getter always returns nil.
    @inlinable public
    subscript<Renderable>(
        _ exterior:HTML.ContainerElement,
        _ interior:HTML.ContainerElement...,
        exterior attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[exterior, { $0 |= value ; attributes(&$0) }]
                {
                    for interior:HTML.ContainerElement in interior
                    {
                        $0.open(interior)
                    }

                    $0 += value

                    for interior:HTML.ContainerElement in interior.reversed()
                    {
                        $0.close(interior)
                    }
                }
            }
        }
    }

    /// Optionally encodes an ``HTML.OutputStreamable`` value to the stream through a **single**
    /// HTML tag, with optional attributes added to the wrapping tag.
    ///
    /// If the value is nil, `attributes` will not be evaluated and nothing will be encoded.
    /// The getter always returns nil.
    @inlinable public
    subscript<Renderable>(tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[tag, { $0 |= value ; attributes(&$0) }] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(svg:SVG.Embedded,
        attributes:(inout SVG.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:SVG.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[svg, { $0 |= value ; attributes(&$0) }] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(link target:String?,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[link: target, { $0 |= value ; attributes(&$0) }] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    /// Appends a `span` element to the stream if the link `target` is nil,
    /// or an `a` element containing the link `target` in its `href` attribute
    /// if non-nil.
    @inlinable public
    subscript(link target:String?,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in },
        content encode:(inout Self) -> ()) -> Void
    {
        mutating get
        {
            if  let target:String
            {
                self[.a, { $0.href = target ; attributes(&$0) }, content: encode]
            }
            else
            {
                self[.span, attributes, content: encode]
            }
        }
    }
}
