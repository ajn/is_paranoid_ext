require 'activerecord'

module IsParanoidExt
  
  def preload_has_one_association(records, reflection, preload_options = {})
    super(records, reflection, paranoid_preload_options(reflection, preload_options))
  end
  
  def preload_has_many_association(records, reflection, preload_options = {})
    super(records, reflection, paranoid_preload_options(reflection, preload_options))
  end
  
  def preload_has_and_belongs_to_many_association(records, reflection, preload_options = {})
    super(records, reflection, paranoid_preload_options(reflection, preload_options))
  end

  private

  def paranoid_preload_options(reflection, preload_options)
    paranoid_preload_opts = preload_options.dup
    if reflection.klass.respond_to?(:restore)
      sql_array  = ["#{reflection.klass.quoted_table_name}.#{reflection.klass.destroyed_field} IS ?"]
      sql_array << reflection.klass.field_not_destroyed
      preload_conditions = paranoid_preload_opts.delete(:conditions) || []
      paranoid_preload_opts.merge(:conditions => merge_conditions(sql_array, preload_conditions))
    end
    paranoid_preload_opts
  end

end

ActiveRecord::Base.send(:extend, IsParanoidExt)
