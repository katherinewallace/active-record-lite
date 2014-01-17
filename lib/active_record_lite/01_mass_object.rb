require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    attributes = self.attributes
    new_attributes.each do |attribute|
      attributes << attribute
    end
  end

  def self.attributes
    raise "must not call #attributes on MassObject directly" if self == MassObject
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr_name,v|
      unless self.class.attributes.include?(attr_name.to_sym)
        raise "mass assignment to unregistered attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=".to_sym, v)
    end
  end
end
