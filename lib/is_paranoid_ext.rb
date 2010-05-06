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
    if (klass = association_id.to_s.classify.constantize) && klass.respond_to?(:restore)
      options.merge!(:conditions => ["#{klass.quoted_table_name}.#{klass.destroyed_field} IS ?", klass.field_not_destroyed])
    end
  end
end

ActiveRecord::Base.send(:extend, IsParanoidExt)
