class StockPriceUpdateSystem 
    def call(args)
        timer_entity = args.state.entities.query(:timer).to_a.flatten.first
        ticks_past = args.state.entities.get_component(timer_entity, :timer)&.ticks_past
        args.state.entities.each_entity(:stock, :price_history) do |entity_id, stock, price_history|
            if true # args.state.tick_count % price_history.update_frequency == 0
                new_price = calculate_price(stock.volatility_type, ticks_past, stock.seed, stock.base_price)
                price_history.history.push(new_price)
                if price_history.history.length > price_history.max_history
                    price_history.history.shift
                end
                stock.current_price = new_price
            end
        end
    end

    def calculate_price(type, time, seed, base)
        price = case type
        when "steady"
            base + noise(seed, time) * 10 + Math.sin(time * 0.5 + seed) * 5
        when "rollercoaster"
            base + Math.sin(time * 0.3 + seed) * 30 + noise(seed, time) * 15
        when "pump_dump"
            max_time = Numeric.rand(15..18) * 60
            if time < max_time
                base + (time / 60.0) * 1 + noise(seed, time) * 3
            else
                decline_factor = ((time - max_time) / 60.0) * 0.3
                new_base = base * 1.2
                new_base - (new_base * decline_factor) + noise(seed, time) * 2
            end
        when "late_bloomer"
            max_time = Numeric.rand(4..8) * 60
            if time < max_time
                base + noise(seed, time) * 1
            else
                growth_factor = ((time - max_time) / 60.0) * 0.2
                base + (base * growth_factor * 1) + Math.sin(time * 0.2 + seed) * 4
            end
        when "fake_out"
            max_time = Numeric.rand(5..12) * 60
            if time < max_time
                base + (time / 60.0) * 0.8 + noise(seed, time) * 2
            else
                decline_factor = ((time - max_time) / 60.0) * 0.2
                new_base = base * 1.1
                new_base - (new_base * decline_factor) + Math.sin(time * 0.5 + seed) * 3
            end
        end
        
        [price, 1.0].max
    end

    def noise(seed, time)
        x = time + seed * 1000
        return (
            Math.sin(x * 0.4) * 1.0 +
            Math.sin(x * 1.1) * 0.5 +
            Math.sin(x * 2.7) * 0.3 +
            Math.sin(x * 5.3) * 0.2 +
            Math.sin(x * 11.7) * 0.1
        ) * 2
    end
end