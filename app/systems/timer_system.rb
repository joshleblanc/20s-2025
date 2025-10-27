class TimerSystem 
    def call(args)
        args.state.entities.each_entity(:timer) do |entity_id, timer|
            ticks_past = args.state.tick_count - timer.tick_count_at_start
            timer.current_seconds = (ticks_past / timer.ticks_per_second).floor
            
            if timer.current_seconds < 0 
                args.state.entities.destroy(entity_id)
            end

            rect = args.layout.rect(row: 0, col: 12, w: 1, h: 1)
            args.outputs.labels << rect.center.merge(text: (20 - timer.current_seconds).to_s, anchor_x: 0.5, anchor_y: 0.5)
        end
    end
end