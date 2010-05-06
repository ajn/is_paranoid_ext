require 'activerecord'

module IsParanoidExt

  def has_many_paranoid(association_id, options = {}, &extension)
    merge_paranoid_options!(association_id, options)
    has_many association_id, options, &extension
  end

  def has_one_paranoid(association_id, options = {}, &extension)
    merge_paranoid_options!(association_id, options)
    has_one association_id, options, &extension
  end
  
  private
  
  def merge_paranoid_options!(association_id, options)
    through_id = options[:through]
    @paranoid_conditions, @paranoid_values = nil, nil
    apply_paranoid_conditions_for(options[:class_name] || association_id)
    apply_paranoid_conditions_for through_id if through_id
    options.merge!(:conditions => merged_paranoid_conditions) unless @paranoid_conditions.nil?
  end
  
  def apply_paranoid_conditions_for(association_id)
    reflection = reflections[association_id.to_sym]
    association_klass = ( reflection.try(:klass) || association_id.to_s.classify.constantize )
    if association_klass && association_klass.respond_to?(:restore)
      @paranoid_conditions ||= []
      @paranoid_conditions << "#{association_klass.quoted_table_name}.#{association_klass.destroyed_field} IS ?"
      @paranoid_values ||= []
      @paranoid_values << association_klass.field_not_destroyed
    end
  end
  
  def merged_paranoid_conditions
    @merged_paranoid_conditions ||= if @paranoid_conditions.any? && @paranoid_values.any?
      [@paranoid_conditions.map{|c|"(#{c})"}.join(' AND ')] + @paranoid_values
    else nil end
  end
end

ActiveRecord::Base.send(:extend, IsParanoidExt)
