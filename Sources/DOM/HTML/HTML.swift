@frozen public
struct HTML
{
    public
    var encoder:ContentEncoder

    /// Creates a completely empty HTML document.
    @inlinable public
    init()
    {
        self.encoder = .init()
    }
}
public extension HTML
{
    /// Encodes an HTML fragment with the provided closure.
    ///
    /// To encode a complete document, use ``document(with:)``.
    @inlinable public
    init(with encode:(inout ContentEncoder) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.encoder)
    }
}
extension HTML:ExpressibleByStringLiteral
{
    /// Creates an HTML document containing the **exact** contents of the given
    /// string literal.
    ///
    /// Use this with caution. This initializer performs no escaping or validation!
    @inlinable public
    init(stringLiteral:String)
    {
        self.init { $0.utf8 = [UInt8].init(stringLiteral.utf8) }
    }
}
public extension HTML
{
    @inlinable public
    var utf8:[UInt8] { self.encoder.utf8 }
}
extension HTML:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(decoding: self.encoder.utf8, as: Unicode.UTF8.self)
    }
}


public extension HTML
{
    /// A value-representation of the ``ContentEncoder/subscript(link:_:)`` encoding interface.
    /// Use this type to reduce verbosity when encoding with rendering systems that generate the
    /// link’s display elements and the target together.
    @frozen public
    struct Link<Display>
    {
        public
        var display:Display
        public
        var target:String?

        @inlinable public
        init(display:Display, target:String?)
        {
            self.display = display
            self.target = target
        }
    }
}
extension HTML.Link:Equatable where Display:Equatable
{
}
extension HTML.Link:Sendable where Display:Sendable
{
}
extension HTML.Link:HTML.OutputStreamable
    where Display:HTML.OutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[link: self.target] = self.display
    }
}


public extension HTML
{
    /// Encodes an HTML document with the provided closure, which includes the prefixed
    /// `<!DOCTYPE html>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var html:Self = "<!DOCTYPE html>"
        try encode(&html.encoder)
        return html
    }
}
