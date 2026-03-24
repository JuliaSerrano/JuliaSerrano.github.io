#!/usr/bin/env ruby

module Jekyll
  class RecipeTagPage < PageWithoutAFile
    def initialize(site, base, dir, tag_name, recipes)
      super(site, base, dir, 'index.html')
      self.data['layout'] = 'recipe-tag'
      self.data['title'] = tag_name
      self.data['recipes'] = recipes.sort_by { |recipe| recipe.data['date'] || Time.at(0) }.reverse
    end
  end

  class RecipeTagsGenerator < Generator
    safe true
    priority :low

    def generate(site)
      recipes = site.collections['recipes']&.docs || []
      recipe_tags = Hash.new { |hash, key| hash[key] = [] }

      recipes.each do |recipe|
        Array(recipe.data['tags']).each do |tag|
          recipe_tags[tag] << recipe
        end
      end

      recipe_tags.each do |tag_name, tagged_recipes|
        slug = Utils.slugify(tag_name, mode: 'default', cased: false)
        site.pages << RecipeTagPage.new(site, site.source, File.join('recipe-tags', slug), tag_name, tagged_recipes)
      end
    end
  end
end
