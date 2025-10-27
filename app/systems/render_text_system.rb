class RenderTextSystem 
    def call(args)
        args.state.entities.each_entity(:text, :rect) do |entity_id, text, rect|
            args.outputs.labels << rect.center.merge(anchor_x: 0.5, anchor_y: 0.5, text: text)
        end
    end
end