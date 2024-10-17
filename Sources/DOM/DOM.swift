@frozen @usableFromInline
enum DOM
{
}

infix operator ?= : AssignmentPrecedence


extension Never:HTML.OutputStreamable
{
    @inlinable public static
    func += (_:inout HTML.ContentEncoder, _:Self)
    {
    }
}
extension Never:SVG.OutputStreamable
{
    @inlinable public static
    func += (_:inout SVG.ContentEncoder, _:Self)
    {
    }
}

extension Optional where Wrapped:HTML.OutputStreamable
{
    @inlinable public static
    func ?= (html:inout HTML.ContentEncoder, wrapped:Wrapped?)
    {
        if  let wrapped:Wrapped
        {
            html += wrapped
        }
    }
}
extension Optional where Wrapped:SVG.OutputStreamable
{
    @inlinable public static
    func ?= (svg:inout SVG.ContentEncoder, wrapped:Wrapped?)
    {
        if  let wrapped:Wrapped
        {
            svg += wrapped
        }
    }
}
