module Repository
  class Criterion
    
    attr_reader :subject, :descriptor, :value, :property_name

    def initialize(options)
      @subject = (options[:subject] || "id").to_s
      @descriptor = options[:descriptor] || "#{@subject} #{default_descriptor}"
      @value = options[:value]
      @value = nil if @value.blank?
      @property_name = options[:property_name] || @subject
    end
    
    def ==(other)
      self.class == other.class &&
      self.subject == other.subject &&
      self.descriptor == other.descriptor &&
      self.value == other.value &&
      self.property_name == other.property_name
    end

    def description
      "#{descriptor} #{described_value}"
    end
    
    def default_descriptor
      self.class.name.gsub(/[A-Z]/, " \\0").gsub(/.*::/, '').downcase.strip
    end

    def described_value
      if value.blank?
        "any"
      elsif value == 0
        "none"
      else
        value
      end
    end
    
    def match?(object)
      object_value = object.send(property_name)
      if value.is_a? Array
        value.detect{|criterion_value| match_value?(criterion_value, object_value)}
      else
        match_value?(value, object_value)
      end
    end

    def +(other)
      And.new(self, other)
    end

    alias_method :&, :+

    def |(other)
      Or.new(self, other)
    end

    def find_in(storage)
      storage.find(self)
    end

protected
    def match_value?(criterion_value, object_value)
      false
    end

public

    class Factory
      # methods are defined inside the relevant Criterion subclasses
    end

    class Equals < Criterion
      def Factory.equals(subject, value)
        Equals.new(:subject => subject, :value => value)
      end

      def match_value?(criterion_value, object_value)
        if object_value.is_a? Fixnum
          object_value == criterion_value.to_i
        else
          object_value == criterion_value
        end
      end

      def value
        case @value
        when Criterion
          @value.value
        else
          @value
        end
      end
    end

    class Key < Equals
      def Factory.key(*args)
        if args.length == 1
          subject = :key
          value = args.first
        else
          subject = args.shift
          value = args.shift
        end
        Key.new(:subject => subject, :value => value)
      end
      
      def initialize(options)
        options[:value] = case options[:value]
        when Fixnum
          [options[:value]]
        when String
          [options[:value].to_i]
        when Array
          options[:value].map{|v|v.to_i} # todo: allow arrays of Criteria too
        else
          options[:value]
        end
        options[:descriptor] ||= "#"
        super(options)
      end
      
      def match?(object)
        object_value = object.send(property_name)
        value.detect{|criterion_value| match_value?(criterion_value, object_value)} || false
      end
      
      def match_value?(criterion_value, object_value)
        object_value == criterion_value
      end
    end

    class Contains < Criterion
      def Factory.contains(subject, value)
        Contains.new(:subject => subject, :value => value)
      end

      protected
      def match_value?(criterion_value, object_value)
        /#{Regexp.escape(criterion_value)}/i =~ object_value
      end
    end

    class Conjunction < Criterion
      attr_reader :criteria
      def initialize(*criteria)
        super(:subject => nil)
        @criteria = criteria
      end
    end

    class And < Conjunction
      def match?(object)
        @criteria.each do |criterion|
          return false unless criterion.match?(object)
        end
        return true
      end
    end

    class Or < Conjunction
      def match?(object)
        @criteria.each do |criterion|
          return true if criterion.match?(object)
        end
        return false
      end
    end

    class Join < Criterion
      attr_reader :referent_class

      def initialize(options)
        super
        @nested_criterion = options[:criterion]
        @referent_class = options[:referent_class]
      end

      def find_in(storage)
        objects = storage.find(@nested_criterion)
        objects.map(&:id)
      end

      def value
        @value ||= begin
          Repository[@referent_class].search(self)
        end
      end
    end
  end
end
