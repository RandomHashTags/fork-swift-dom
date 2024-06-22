extension HTML.AttributeEncoder
{
    @frozen @usableFromInline
    enum CustomData
    {
        case data(String)
    }
}
extension HTML.AttributeEncoder.CustomData:DOM.Attribute
{
    @inlinable
    var name:String
    {
        switch self
        {
        case .data(let suffix): "data-\(suffix)"
        }
    }
}
