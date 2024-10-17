public extension HTML
{
    @dynamicMemberLookup
    @frozen public
    struct AttributeEncoder:StreamingEncoder
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
public extension HTML.AttributeEncoder
{
    /// Serializes an empty attribute, if the assigned boolean is true.
    /// Does nothing if it is false. The getter always returns false.
    @inlinable public
    subscript(name name:HTML.Attribute) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[name: name] = bool ? "" : nil
        }
    }

    @inlinable public
    subscript(name name:HTML.Attribute) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self.utf8 += DOM.Property<HTML.Attribute>.init(name, text)
            }
        }
    }
}
public extension HTML.AttributeEncoder
{
    /// Serializes a `data-` attribute with the given name suffix. The suffix should **not**
    /// include the `data-` prefix, and the encoder will not escape special characters in the
    /// custom attribute name.
    @inlinable public
    subscript(data suffix:String) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self.utf8 += DOM.Property<CustomData>.init(.data(suffix), text)
            }
        }
    }
}

public extension HTML.AttributeEncoder
{
    @inlinable public
    subscript(dynamicMember path:KeyPath<HTML.Attribute.Factory, HTML.Attribute>) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[name: HTML.Attribute.Factory.init()[keyPath: path]] = bool
        }
    }
    @inlinable public
    subscript(dynamicMember path:KeyPath<HTML.Attribute.Factory, HTML.Attribute>) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            self[name: HTML.Attribute.Factory.init()[keyPath: path]] = text
        }
    }
}



public extension HTML.AttributeEncoder
{
    @inlinable public
    var property:HTML.Attribute.Property?
    {
        get { nil }
        set (value)
        {
            self[name: .property] = value?.rawValue
        }
    }

    @inlinable public
    var rel:HTML.Attribute.Rel?
    {
        get { nil }
        set (value)
        {
            self[name: .rel] = value?.rawValue
        }
    }
}
