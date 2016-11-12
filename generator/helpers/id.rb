module ID

  class << self
    def included(other_module)
      other_module.extend(ID::IDClassMethods)
    end
  end

  module IDClassMethods

    def new(*args)
      @next_id ||= 0
      @next_id += 1
      super(@next_id,*args)
    end

  end

  attr_reader :id

end