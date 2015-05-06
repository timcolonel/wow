module Renderer
  class ERB < OpenStruct
    def self.render(t, h)
      Renderer::ERB.new(h)._render(t)
    end

    def self.render_file(file, h)
      Renderer::ERB.new(h)._render(IO.read(file))
    end

    def _render(template)
      ::ERB.new(template).result(binding)
    end
  end
end