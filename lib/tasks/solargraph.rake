require 'fileutils'

namespace :solargraph do
  task update_model_definitions: :environment do
    if Rails.env.development?
      Rails.application.eager_load! unless Rails.application.config.cache_classes

      ApplicationRecord.descendants.each do |model|
        next if model.name.blank?

        def_file = Rails.root.join('config', 'model_definitions', "#{model.name.underscore}.rb")
        FileUtils.mkdir_p File.dirname(def_file)

        File.open(def_file, 'w') do |file|
          file << "class #{model.name}\n"
          klass = model.name.constantize
          klass.attribute_names.each do |name|
            file << "#   @!attribute [rw] #{name}\n"
            file << "#     @return [#{ruby_type[klass.type_for_attribute(name).type]}]\n"
          end
          file << "end\n"
        end
      end
    end
  end
end

def ruby_type
  {
    array: 'Array',
    boolean: 'Boolean',
    date: 'Date',
    datetime: 'DateTime',
    decimal: 'Decimal',
    float: 'Float',
    integer: 'Integer',
    string: 'String',
    text: 'String',
    time: 'Time'
  }
end
