@frozen public
struct SVG
{
    public
    var encoder:ContentEncoder

    /// Creates a completely empty SVG document.
    @inlinable public
    init()
    {
        self.encoder = .init()
    }
}
public extension SVG
{
    /// Encodes an SVG fragment with the provided closure.
    ///
    /// To encode a complete document, use ``document(with:)``.
    @inlinable public
    init(with encode:(inout ContentEncoder) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.encoder)
    }
}
extension SVG:ExpressibleByStringLiteral
{
    /// Creates an SVG document containing the **exact** contents of the given
    /// string literal.
    ///
    /// Use this with caution. This initializer performs no escaping or validation!
    @inlinable public
    init(stringLiteral:String)
    {
        self.init { $0.utf8 = [UInt8].init(stringLiteral.utf8) }
    }
}
public extension SVG
{
    @inlinable public
    var utf8:[UInt8] { self.encoder.utf8 }
}
extension SVG:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(decoding: self.encoder.utf8, as: Unicode.UTF8.self)
    }
}


#if canImport(Glibc)
import func Glibc.cos
import func Glibc.sin
#elseif canImport(Darwin)
import func Darwin.cos
import func Darwin.sin
#endif


public extension SVG
{
    @frozen public
    struct Point<Scalar> where Scalar:CustomStringConvertible
    {
        public
        var x:Scalar
        public
        var y:Scalar

        @inlinable public
        init(_ x:Scalar, _ y:Scalar)
        {
            self.x = x
            self.y = y
        }
    }
}
extension SVG.Point:Equatable where Scalar:Equatable
{
}
extension SVG.Point:Hashable where Scalar:Hashable
{
}
extension SVG.Point:Sendable where Scalar:Sendable
{
}
public extension SVG.Point<Float>
{
    @inlinable public
    init(radians:Float, radius:Float = 1.0)
    {
        self.init(radius * _cos(radians), radius * -_sin(radians))
    }
}
public extension SVG.Point<Double>
{
    @inlinable public
    init(radians:Double, radius:Double = 1.0)
    {
        self.init(radius * _cos(radians), radius * -_sin(radians))
    }
}
extension SVG.Point:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.x),\(self.y)" }
}


extension SVG
{
    /// Encodes an SVG document with the provided closure, which includes the prefixed
    /// `<?xml version='1.0' encoding='UTF-8' standalone='no'?>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var svg:Self = "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
        try encode(&svg.encoder)
        return svg
    }
}
