require 'activerecord'

module IsParanoidExt

  def has_many_paranoid(association_id, options = {}, &extension)
    merge_paranoid_options!(association_id, options)
    has_many association_id, options, &extension
  end

  def has_and_belongs_to_many_paranoid(association_id, options = {}, &extension)
    merge_paranoid_options!(association_id, options)
    has_and_belongs_to_many association_id, options, &extension
  end
  
  def has_one_paranoid(association_id, options = {}, &extension)
    merge_paranoid_options!(association_id, options)
    has_one association_id, options, &extension
  end

  private
  
  def merge_paranoid_options!(association_id, options)
    @paranoid_conditions = []
    apply_paranoid_conditions_for(options[:class_name] || association_id)
    apply_paranoid_conditions_for options[:through] if options[:through]
    unless @paranoid_conditions.empty?
      options.merge!( :conditions => merge_conditions( @paranoid_conditions + [sanitize_sql(options.delete(:conditions) || [])] ) ) 
      @paranoid_conditions = []
    end
  end
  
  def apply_paranoid_conditions_for(association_id)
    reflection = reflections[association_id.to_sym]
    association_klass = ( reflection.try(:klass) || association_id.to_s.classify.constantize )
    if association_klass && association_klass.respond_to?(:restore)
      sql_array = ["#{association_klass.quoted_table_name}.#{association_klass.destroyed_field} IS ?"]
      sql_array << association_klass.field_not_destroyed
      @paranoid_conditions <<  sanitize_sql_array(sql_array)
    end
  end
  
end

ActiveRecord::Base.send(:extend, IsParanoidExt)
