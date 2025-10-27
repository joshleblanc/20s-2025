class HandleClickSystem 
    def call(args)
        args.state.entities.each_entity(:on_click, :rect) do |entity_id, on_click, rect|
            if args.inputs.mouse.intersect_rect?(rect) && args.inputs.mouse.click
                on_click.call(args)
            end
        end
    end
end