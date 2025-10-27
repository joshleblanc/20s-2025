class RenderRectsSystem 
    def call(args)
        args.state.entities.each_entity(:rect) do |entity_id, rect|
            args.outputs.borders << rect.rect.merge(r: 0, g: 0, b: 0, a: 255)
        end
    end
end