=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

module Arachni::OptionGroups

# Options for audit scope/coverage, mostly decides what types of elements
# should be considered.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Audit < Arachni::OptionGroup

    # @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
    class Error < Error

        # @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
        class InvalidLinkTemplate < Error
        end
    end

    # @note Default is `false`.
    #
    # @return   [Bool]
    #   If enabled, all element audits will be performed with both `GET` and
    #   `POST` HTTP methods.
    #
    # @see Element::Capabilities::Mutable::MUTATION_OPTIONS
    # @see Element::Capabilities::Mutable#each_mutation
    # @see Element::Capabilities::Mutable#switch_method
    attr_accessor :with_both_http_methods

    # @return    [Array<String>]
    #   Vectors to exclude from the audit, by name.
    #
    # @see Element::Capabilities::Auditable#audit
    attr_accessor :exclude_vectors

    # @note Default is `false`.
    #
    # @return    [Bool]
    #   Audit links.
    #
    # @see Element::Link
    # @see Element::Capabilities::Auditable#audit
    attr_accessor :links
    alias :link_doms  :links
    alias :link_doms= :links=

    # @note Default is `false`.
    #
    # @return    [Bool]
    #   Audit forms.
    #
    # @see Element::Form
    # @see Element::Capabilities::Auditable#audit
    attr_accessor :forms
    alias :form_doms  :forms
    alias :form_doms= :forms=

    # @note Default is `false`.
    #
    # @return    [Bool]
    #   Audit cookies.
    #
    # @see Element::Cookie
    # @see Element::Capabilities::Auditable#audit
    attr_accessor :cookies
    alias :cookie_doms  :cookies
    alias :cookie_doms= :cookies=

    # @note Default is `false`.
    #
    # @return    [Bool]
    #   Like {#cookies} but all cookie audits are submitted along with any other
    #   available element on the page.
    #
    # @see Element::Cookie#each_mutation
    # @see Element::Capabilities::Auditable#audit
    attr_accessor :cookies_extensively

    # @note Default is `false`.
    #
    # @return    [Bool]
    #   Audit HTTP request headers.
    attr_accessor :headers

    # @return   [Array<Regexp>]
    #   Regular expressions with named captures, serving as templates used to
    #   extract input vectors from links.
    #
    # @see Element::LinkTemplate
    attr_accessor :link_templates
    alias :link_template_doms  :link_templates

    set_defaults(
        exclude_vectors: [],
        link_templates:  []
    )

    # @param    [Array<Regexp>] templates
    #   Regular expressions with named captures, serving as templates used to
    #   extract input vectors from paths.
    #
    # @see Element::LinkTemplate
    def link_templates=( templates )
        return @link_templates = [] if !templates

        @link_templates = [templates].flatten.compact.map do |s|
            template = s.is_a?( Regexp ) ? s : Regexp.new( s.to_s )

            if template.names.empty?
                fail Error::InvalidLinkTemplate,
                     "Template '#{template}' includes no named captured."
            end

            template
        end
    end
    alias :link_template_doms= :link_templates=

    def exclude_vectors=( vectors )
        @exclude_vectors = [vectors].flatten.compact.map(&:to_s)
    end

    # Enables auditing of element types.
    #
    # @param    [String, Symbol, Array] element_types
    #   Allowed:
    #
    #   * `:links`
    #   * `:forms`
    #   * `:cookies`
    #   * `:headers`
    def elements( *element_types )
        element_types.flatten.compact.each do |type|
            self.send( "#{type}=", true ) rescue self.send( "#{type}s=", true )
        end
        true
    end
    alias :elements= :elements
    alias :element   :elements
    alias :element=  :element

    # Disables auditing of element types.
    #
    # @param    [String, Symbol, Array] element_types
    #   Allowed:
    #
    #   * `:links`
    #   * `:forms`
    #   * `:cookies`
    #   * `:headers`
    def skip_elements( *element_types )
        element_types.flatten.compact.each do |type|
            self.send( "#{type}=", false ) rescue self.send( "#{type}s=", false )
        end
        true
    end
    alias :skip_element :skip_elements

    # Get audit settings for the given element types.
    #
    # @param    [String, Symbol, Array] element_types
    #   Allowed:
    #
    #   * `:links`
    #   * `:forms`
    #   * `:cookies`
    #   * `:headers`
    #
    # @return   [Bool]
    def elements?( *element_types )
        !(element_types.flatten.compact.map do |type|
            !!(self.send( "#{type}?" ) rescue self.send( "#{type}s?" ))
        end.uniq.include?( false ))
    end
    alias :element? :elements?

    [:links, :forms, :cookies, :headers, :cookies_extensively,
     :with_both_http_methods, :link_doms, :form_doms, :cookie_doms].each do |attribute|
        define_method "#{attribute}?" do
            !!send( attribute )
        end
    end

    # @return   [Bool]
    #   `true` if link templates have been specified, `false` otherwise.
    def link_templates?
        @link_templates.any?
    end
    alias :link_template_doms? :link_templates?

    def to_rpc_data
        d = super
        d['link_templates'] = d['link_templates'].map(&:to_s)
        d
    end

end
end
