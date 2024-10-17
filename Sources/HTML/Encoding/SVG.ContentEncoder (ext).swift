import DOM

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
