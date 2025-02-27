extension SVG
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
extension SVG.ContentEncoder
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
extension SVG.ContentEncoder:DOM.ContentEncoder
{
    @usableFromInline
    typealias AttributeEncoder = SVG.AttributeEncoder

    /// Appends a *raw* UTF-8 code unit to the output stream.
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.utf8.append(codeunit)
    }
}
extension SVG.ContentEncoder
{
    /// Appends an *unescaped* UTF-8 code unit to the output stream.
    /// If the code unit is one of the ASCII characters `&` `<`, or `>`,
    /// this function replaces it with the corresponding XML entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        self.utf8 += DOM.UTF8.init(codeunit)
    }
    /// Writes an opening SVG tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func open(_ tag:SVG.ContainerElement,
        with yield:(inout SVG.AttributeEncoder) -> () = { _ in })
    {
        self.emit(opening: tag, with: yield)
    }
    /// Writes a closing SVG tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func close(_ tag:SVG.ContainerElement)
    {
        self.emit(closing: tag)
    }
}
extension SVG.ContentEncoder
{
    @inlinable public
    subscript(_ tag:SVG.ContainerElement,
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
    subscript(_ tag:SVG.ContainerElement,
        attributes:(inout SVG.AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag, with: attributes)
            encode(&self)
            self.close(tag)
        }
    }
}


extension SVG.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(_ tag:SVG.ContainerElement,
        attributes:(inout SVG.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:SVG.OutputStreamable
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
