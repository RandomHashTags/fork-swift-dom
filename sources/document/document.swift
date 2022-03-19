public 
protocol TagDomain:Equatable
{
    var name:String 
    {
        get 
    }
}
extension TagDomain where Self:RawRepresentable, RawValue == String
{
    @inlinable public
    var name:String
    { 
        self.rawValue 
    }
}
public 
protocol LeafDomain:TagDomain
{
    // indicates if the leaf should be rendered '<example>' (true) or '<example/>' (false)
    var void:Bool 
    {
        get 
    }
}
public 
protocol ContainerDomain:TagDomain
{
    static 
    var root:Self
    {
        get 
    }
}
public 
protocol DocumentDomain 
{
    associatedtype Container    where Container:ContainerDomain
    associatedtype Leaf         where      Leaf:LeafDomain
}
extension DocumentDomain 
{
    public 
    typealias StaticElement = DocumentElement<Self, Never>
    public 
    typealias Element<ID> = DocumentElement<Self, ID> 
}

@frozen public
enum DocumentElement<Domain, ID> where Domain:DocumentDomain
{
    case root       (any AnyDocumentRoot & Sendable)
    
    case container  (Domain.Container, id:ID? = nil, attributes:[String: String] = [:], content:[Self] = []) 
    case leaf       (Domain.Leaf,      id:ID? = nil, attributes:[String: String] = [:]) 
    case text       (escaped:String)
    case anchor                       (id:ID)
    
    @inlinable public static 
    func text(escaping unescaped:String) -> Self
    {
        .text(escaped: Document.escape(unescaped))
    }
    
    @inlinable public static 
    subscript(_ leaf:Domain.Leaf, id id:ID? = nil, @Attributes attributes:() -> [String: String]) 
        -> Self
    {
        .leaf(leaf, id: id, attributes: attributes())
    }
    @inlinable public static 
    subscript(_ leaf:Domain.Leaf, id id:ID? = nil) 
        -> Self
    {
        .leaf(leaf, id: id)
    }
    
    @inlinable public static 
    subscript(_ container:Domain.Container, id id:ID? = nil, 
        @Attributes attributes attributes:() -> [String: String], 
        @Content    content       content:() -> [Self] = { [] }) 
        -> Self
    {
        .container(container, id: id, attributes: attributes(), content: content())
    }
    @inlinable public static 
    subscript(_ container:Domain.Container, id id:ID? = nil, @Content content:() -> [Self]) 
        -> Self
    {
        .container(container, id: id, content: content())
    }
    @inlinable public static 
    subscript(_ container:Domain.Container, id id:ID? = nil) 
        -> Self
    {
        .container(container, id: id)
    }
}

public 
typealias StaticDocumentRoot<Domain> = DocumentRoot<Domain, Never> where Domain:DocumentDomain

public 
protocol AnyDocumentRoot
{
     associatedtype Domain where Domain:DocumentDomain
     associatedtype ID 
     
     var element:DocumentElement<Domain, ID> 
     {
         get
     }
}
// needed because we cannot access `self.element` from a protocol existential
extension AnyDocumentRoot 
{
    @inlinable public 
    var rendered:String 
    {
        self.element.rendered 
    }
    @inlinable public 
    var plain:String 
    {
        self.element.plain
    }
}
@frozen public 
struct DocumentRoot<Domain, ID>:AnyDocumentRoot where Domain:DocumentDomain
{
    public 
    var id:ID?
    public 
    var attributes:[String: String]
    public
    var content:[DocumentElement<Domain, ID>]
    
    @inlinable public 
    var element:DocumentElement<Domain, ID> 
    {
        .container(.root, id: self.id, attributes: self.attributes, content: self.content)
    }
    
    @inlinable public 
    init(id:ID? = nil,   
        @DocumentElement<Domain, ID>.Attributes attributes:() -> [String: String], 
        @DocumentElement<Domain, ID>.Content       content:() -> [DocumentElement<Domain, ID>] = { [] }) 
    {
        self.id         = id
        self.attributes = attributes()
        self.content    = content()
    }
    @inlinable public 
    init(id:ID? = nil, 
        @DocumentElement<Domain, ID>.Content content:() -> [DocumentElement<Domain, ID>]) 
    {
        self.id         = id
        self.attributes = [:]
        self.content    = content()
    }
    @inlinable public 
    init(id:ID? = nil) 
    {
        self.id         = id
        self.attributes = [:]
        self.content    = []
    }
}

public 
enum Document 
{
    @available(*, deprecated, renamed: "StaticDocumentRoot")
    public
    typealias Static<Domain> = StaticDocumentRoot<Domain> where Domain:DocumentDomain
    public 
    typealias Dynamic<Domain, ID> = DocumentRoot<Domain, ID>  where Domain:DocumentDomain
    
    @inlinable public static 
    func escape(_ unescaped:String) -> String 
    {
        var string:String = ""
        for character:Character in unescaped 
        {
            switch character 
            {
            case "<"            : string += "&lt;"
            case ">"            : string += "&gt;"
            case "&"            : string += "&amp;"
            case "'"            : string += "&apos;"
            case "\""           : string += "&quot;"
            case let character  : string.append(character)
            }
        }
        return string
    }
    
    @available(*, deprecated, renamed: "DocumentElement")
    public 
    typealias Element<Domain, ID> = DocumentElement<Domain, ID>
        where Domain:DocumentDomain
    
    @available(*, deprecated, renamed: "DocumentElement.Attributes")
    public 
    typealias AttributesBuilder<Domain, ID> = DocumentElement<Domain, ID>.Attributes
        where Domain:DocumentDomain
    
    @available(*, deprecated, renamed: "DocumentElement.Content")
    public 
    typealias ElementsBuilder<Domain, ID> = DocumentElement<Domain, ID>.Content
        where Domain:DocumentDomain
    
    @available(*, deprecated, renamed: "DocumentElement.Prose")
    public 
    typealias InlineBuilder<Domain, ID> = DocumentElement<Domain, ID>.Prose
        where Domain:DocumentDomain
    
    @available(*, deprecated, renamed: "DocumentElement.Prose")
    public 
    typealias Inline<Domain, ID> = DocumentElement<Domain, ID>.Prose
        where Domain:DocumentDomain
}
extension DocumentRoot:Sendable where ID:Sendable, Domain.Leaf:Sendable, Domain.Container:Sendable
{
}
extension DocumentElement:Sendable where ID:Sendable, Domain.Leaf:Sendable, Domain.Container:Sendable
{
}

// rendering 
extension DocumentElement
{
    @inlinable public 
    var plain:String 
    {
        switch self 
        {
        case .root      (let foreign): 
            return foreign.plain
        case .text      (escaped: let text):
            return text 
        case .leaf      (_, id: _, attributes: _): 
            return ""
        case .container (_, id: _, attributes: _, content: let content):
            return content.map(\.plain).joined()
        case .anchor: 
            return ""
        }
    }
    @inlinable public 
    var rendered:String 
    {
        let attributes:[String: String], 
            children:[Self]??, 
            type:String
        switch self 
        {
        case .root      (let foreign): 
            return foreign.rendered
        case .text      (escaped: let text):
            return text 
        
        case .leaf      (let element, id: _, attributes: let dictionary): 
            attributes  = dictionary
            children    = element.void ? .none : .some(nil) 
            type        = element.name
        case .container (let element, id: _, attributes: let dictionary, content: let content):
            attributes  = dictionary
            children    = .some(content)
            type        = element.name
        case .anchor: 
            return ""
        }
        
        var head:String         = type 
        for (key, value):(String, String) in attributes.sorted(by: { $0.key < $1.key })
        { 
            head               += " \(key)=\"\(value)\"" 
        }
        guard let enclosed:[Self]?  = children 
        else 
        {
            return "<\(head)>"
        }
        guard let content:[Self]    = enclosed
        else 
        {
            return "<\(head)/>"
        }
        return "<\(head)>\(content.map{ $0.rendered }.joined())</\(type)>"
    }
    @inlinable public 
    func stripping(where predicate:(Domain.Container) throws -> Bool) rethrows -> [Self] 
    {
        guard case .container(let type, id: let id, attributes: let attributes, content: let content) = self
        else 
        {
            return [self] 
        }
        let stripped:[Self] = try content.flatMap 
        {
            try $0.stripping(where: predicate)
        } 
        if try predicate(type)
        {
            return stripped 
        }
        else 
        {
            return [.container(type, id: id, attributes: attributes, content: stripped)]
        }
    }
    @inlinable public 
    func stripping(_ container:Domain.Container) -> [Self] 
    {
        self.stripping 
        {
            if case container = $0
            {
                return true 
            }
            else 
            {
                return false 
            }
        }
    }
}
/* extension XML.Domain
{
    static 
    func render<S, ID>(_ content:S) -> String
        where   S:Sequence, ID:XML.ID, S.Element == DocumentElement<Self, ID>
    {
        var concatenated:String = ""
        for element:DocumentElement<Self, ID> in content 
        {
            concatenated += element.rendered 
        }
        return concatenated
    }
} */
public 
protocol DocumentArrayBuilder 
{
    associatedtype Element 
}
extension DocumentArrayBuilder
{
    @inlinable public static 
    func buildExpression(_ element:Element?) -> [Element]
    {
        element.map{ [$0] } ?? []
    }
    @inlinable public static 
    func buildExpression(_ element:Element) -> [Element]
    {
        [element]
    }
    @inlinable public static 
    func buildExpression(_ elements:[Element]) -> [Element]
    {
        elements
    }
    @inlinable public static 
    func buildExpression<S>(_ elements:S) -> [Element]
        where S:Sequence, S.Element == Element 
    {
        [Element].init(elements)
    }
    @inlinable public static 
    func buildBlock(_ elements:[Element]...) -> [Element]
    {
        elements.flatMap{ $0 }
    }
    @inlinable public static 
    func buildArray(_ elements:[[Element]]) -> [Element]
    {
        elements.flatMap{ $0 }
    }
    @inlinable public static 
    func buildOptional(_ element:[Element]?) -> [Element]
    {
        element ?? []
    }
    @inlinable public static 
    func buildEither(first:[Element]) -> [Element]
    {
        first
    }
    @inlinable public static 
    func buildEither(second:[Element]) -> [Element]
    {
        second
    }
}

// attributes 
public 
protocol DocumentAttribute
{
    associatedtype Expression = String
    static 
    func value(from expression:Expression) -> String
    static 
    var name:String 
    {
        get 
    }
}
extension DocumentAttribute
{
    @inlinable public static 
    func item(from expression:Expression) -> (key:String, value:String) 
    {
        (Self.name, Self.value(from: expression))
    }
}
extension DocumentAttribute where Expression == Bool  
{
    @inlinable public static 
    func value(from expression:Expression) -> String
    {
        expression ? "true" : "false"
    }
}
extension DocumentAttribute where Expression == String
{
    @inlinable public static 
    func value(from expression:Expression) -> String
    {
        expression
    }
}
extension DocumentAttribute where Expression == Self, Self:RawRepresentable, Self.RawValue == String 
{
    @inlinable public static 
    func value(from expression:Expression) -> String
    {
        expression.rawValue
    }
}

extension DocumentElement 
{
    // by default, only (key:String, value:String) expressions are accepted. 
    // some `Domain`s provide additional DSL
    @resultBuilder 
    public 
    enum Attributes:DocumentArrayBuilder 
    {
        public 
        typealias Element = (key:String, value:String)
        
        @inlinable public static 
        func buildFinalResult(_ attributes:[(key:String, value:String)]) -> [String: String]
        {
            var dictionary:[String: String] = [:]
            for (key, value):(String, String) in attributes 
                where dictionary.updateValue(value, forKey: key) != nil
            {
                print("warning: duplicate attribute '\(key)': '\(value)'")
            }
            return dictionary
        }
    }
    @resultBuilder 
    public 
    enum Content:DocumentArrayBuilder
    {
        public 
        typealias Element = DocumentElement<Domain, ID>
        
        @inlinable public static 
        func buildExpression(_ inline:Element.Prose) -> [Element]  
        {
            inline.elements
        }
        @inlinable public static 
        func buildExpression<Domain, ID>(_ foreign:DocumentRoot<Domain, ID>) -> [Element]
            where Domain:DocumentDomain, Domain.Leaf:Sendable, Domain.Container:Sendable, ID:Sendable
        {
            [Element.root(foreign)]
        }
        /* @inlinable public static 
        func buildExpression(_ empty:Domain.Container) -> [Element]  
        {
            [Element.container(empty)]
        }
        @inlinable public static 
        func buildExpression(_ empty:Domain.Leaf) -> [Element]  
        {
            [Element.leaf(empty)]
        } */
        @inlinable public static 
        func buildExpression(_ unescaped:String) -> [Element]  
        {
            [Element.text(escaping: unescaped)]
        }
    }
    @resultBuilder 
    @frozen public 
    struct Prose:ExpressibleByStringInterpolation
    {
        @frozen public 
        struct StringInterpolationType:StringInterpolationProtocol 
        {
            public 
            typealias Element = DocumentElement<Domain, ID>
            
            public 
            var elements:[Element] 
            @inlinable public 
            init(literalCapacity:Int, interpolationCount:Int)
            {
                self.elements = [] 
                self.elements.reserveCapacity(literalCapacity + interpolationCount)
            }
            
            @inlinable public mutating 
            func appendInterpolation<T>(_ value:T) where T:CustomStringConvertible
            {
                self.appendLiteral(value.description)
            }
            @inlinable public mutating 
            func appendLiteral(_ unescaped:String)
            {
                self.appendInterpolation(.text(escaping: unescaped))
            }
            @inlinable public mutating 
            func appendInterpolation(_ element:Element)
            {
                self.elements.append(element)
            }
            
            @inlinable public mutating 
            func appendInterpolation<T>(_ value:T, as container:Domain.Container) where T:CustomStringConvertible
            {
                self.appendInterpolation(value.description, as: container)
            }
            @inlinable public mutating 
            func appendInterpolation(_ unescaped:String, as container:Domain.Container)
            {
                self.appendInterpolation(.text(escaping: unescaped), as: container)
            }
            @inlinable public mutating 
            func appendInterpolation(_ element:Element, as container:Domain.Container)
            {
                self.elements.append(.container(container, content: [element]))
            }
        }
        
        public 
        let elements:[DocumentElement<Domain, ID>]
        
        @inlinable public 
        init(stringInterpolation:StringInterpolationType) 
        {
            self.elements = stringInterpolation.elements 
        }
        @inlinable public 
        init(stringLiteral:String) 
        {
            self.elements = [.text(escaping: stringLiteral)]
        }
    }
}
extension DocumentElement.Prose:DocumentArrayBuilder 
{
    public 
    typealias Element = Self 
    @inlinable public static 
    func buildFinalResult(_ elements:[Self]) -> [[DocumentElement<Domain, ID>]]
    {
        elements.map(\.elements)
    }
}
