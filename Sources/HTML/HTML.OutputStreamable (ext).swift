import DOM

extension HTML.OutputStreamable
{
    /// Calls ``+=(_:_:)`` as an instance method. This method only exists to allow encoding
    /// existentials.
    @inlinable
    func encode(to html:inout HTML.ContentEncoder) { html += self }
}
