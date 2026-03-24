#!/usr/bin/env ruby

module Jekyll
  class RecipeCategoryPage < PageWithoutAFile
    def initialize(site, base, dir, category_name, recipes)
      super(site, base, dir, 'index.html')
      self.data['layout'] = 'recipe-category'
      self.data['title'] = category_name
      self.data['recipes'] = recipes.sort_by { |recipe| recipe.data['date'] || Time.at(0) }.reverse
    end
  end

  class RecipeCategoriesGenerator < Generator
    safe true
    priority :low

    def generate(site)
      recipes = site.collections['recipes']&.docs || []
      recipe_categories = Hash.new { |hash, key| hash[key] = [] }

      recipes.each do |recipe|
        Array(recipe.data['categories']).each do |category|
          recipe_categories[category] << recipe
        end
      end

      recipe_categories.each do |category_name, categorized_recipes|
        slug = Utils.slugify(category_name, mode: 'default', cased: false)
        site.pages << RecipeCategoryPage.new(
          site,
          site.source,
          File.join('recipe-categories', slug),
          category_name,
          categorized_recipes
        )
      end
    end
  end
end
