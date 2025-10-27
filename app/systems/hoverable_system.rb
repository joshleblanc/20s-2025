class HoverableSystem
    def call(args)
        args.state.entities.each_entity(:hoverable, :rect) do |entity_id, hoverable, rect|
            if args.inputs.mouse.intersect_rect?(rect)
                args.outputs.borders << rect.merge(r: 255, g: 0, b: 0, a: 255)
            end
        end
    end
end