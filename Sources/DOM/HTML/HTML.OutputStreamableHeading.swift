extension HTML
{
    /// A type that wraps its ``display [25686]`` value in an `a` element with `href` set to a
    /// fragment pointing to its ``Identifiable/id [8T2WS]`` value.
    public
    protocol OutputStreamableHeading<Display>:HTML.OutputStreamableAnchor
    {
        associatedtype Display:HTML.OutputStreamable = String

        var display:Display { get }
    }
}
/// The name of this protocol is ``HTML.OutputStreamableHeading``.
extension HTML.OutputStreamableHeading where Self:CustomStringConvertible
{
    @inlinable public
    var display:String { self.description }
}


extension HTML.OutputStreamableHeading
{
    @inlinable public static
    func += (hx:inout HTML.ContentEncoder, self:Self)
    {
        hx[.a] { $0.href = "#\(self.id)" } = self.display
    }
}
