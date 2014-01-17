class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { self.instance_variable_get("@#{name}".to_sym) }
      define_method("#{name}=".to_sym) do |arg|
        self.instance_variable_set("@#{name}".to_sym, arg)
      end
    end
  end
end
