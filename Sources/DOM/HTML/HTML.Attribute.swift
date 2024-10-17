import DynamicMemberFactoryMacro

public extension HTML
{
    @GenerateDynamicMemberFactory(excluding: "rel", "property")
    @frozen public
    enum Attribute:String, DOM.Attribute, Equatable, Hashable, Sendable
    {
        case accept
        case accept_charset = "accept-charset"
        case accesskey
        case action
        case align
        case allow
        case alt
        case async
        case autocapitalize
        case autocomplete
        case autofocus
        case autoplay
        case background
        case bgcolor
        case border
        case buffered
        case capture
        case challenge
        case charset
        case checked
        case cite
        case `class`
        case code
        case codebase
        case color
        case cols
        case colspan
        case content
        case contenteditable
        case contextmenu
        case controls
        case coords
        case crossorigin
        case csp
        case data
        case datetime
        case `default`
        case `defer`
        case dir
        case dirname
        case disabled
        case download
        case draggable
        case enctype
        case enterkeykint
        case `for`
        case form
        case formaction
        case formenctype
        case formmethod
        case formnovalidate
        case formtarget
        case headers
        case height
        case hidden
        case high
        case href
        case hreflang
        case http_equiv = "http-equiv"
        case icon
        case id
        case importance
        case integrity
        case intrinsicsize
        case inputmode
        case ismap
        case itemprop
        case keytype
        case kind
        case label
        case lang
        case language
        case loading
        case list
        case loop
        case low
        case manifest
        case max
        case maxlength
        case minlength
        case media
        case method
        case min
        case multiple
        case muted
        case name
        case novalidate
        case open
        case optimum
        case pattern
        case ping
        case placeholder
        case poster
        case preload
        case radiogroup
        case readonly
        case referrerpolicy
        case rel
        case required
        case reversed
        case role
        case rows
        case rowspan
        case sandbox
        case scope
        case scoped
        case selected
        case shape
        case size
        case sizes
        case slot
        case span
        case spellcheck
        case src
        case srcdoc
        case srclang
        case srcset
        case start
        case step
        case style
        case summary
        case tabindex
        case target
        case title
        case translate
        case type
        case usemap
        case value
        case width
        case wrap

        /// A non-standard HTML attribute defined in [RDFa](https://en.wikipedia.org/wiki/RDFa)
        /// for use in the `<meta>` tag.
        case property
    }
}

public extension HTML.Attribute
{
    /// See https://ogp.me/
    @frozen public
    enum Property:String, Equatable, Hashable, Sendable
    {
        case og_audio = "og:audio"
        case og_audio_type = "og:audio:type"

        case og_image = "og:image"
        case og_image_alt = "og:image:alt"
        case og_image_type = "og:image:type"
        case og_image_width = "og:image:width"
        case og_image_height = "og:image:height"

        case og_video = "og:video"
        case og_video_type = "og:video:type"
        case og_video_width = "og:video:width"
        case og_video_height = "og:video:height"

        case og_description = "og:description"
        case og_determiner = "og:determiner"
        case og_locale = "og:locale"
        case og_locale_alternate = "og:locale:alternate"
        case og_site_name = "og:site_name"
        case og_title = "og:title"
        case og_type = "og:type"
        case og_url = "og:url"
    }
}

public extension HTML.Attribute
{
    /// https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel
    @frozen public
    enum Rel:String, Equatable, Hashable, Sendable
    {
        case alternate
        case author
        case bookmark
        case canonical
        case dnsPrefetch = "dns-prefetch"
        case external
        case help
        case icon
        case license
        case manifest
        case me
        case modulepreload
        case next
        case nofollow
        case noopener
        case noreferrer
        case opener
        case pingback
        case preconnect
        case prefetch
        case preload
        case prerender
        case prev
        case search
        case stylesheet
        case tag

        //  Unofficial extensions.
        //  See: https://github.com/whatwg/html/issues/5367.
        case google_sponsored = "sponsored"
        case google_ugc = "ugc"
    }
}
extension HTML.Attribute.Rel:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
