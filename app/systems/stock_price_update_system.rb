class StockPriceUpdateSystem 
    def call(args)
        args.state.entities.each_entity(:stock, :price_history) do |entity_id, stock, price_history|
            if true #args.state.tick_count % price_history.update_frequency == 0
                new_price = calculate_price(stock.volatility_type, args.state.tick_count / price_history.update_frequency, stock.seed, stock.base_price)
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
            if time < 20
                base + time * 3 + noise(seed, time) * 10
            else
                base + (40 - time) * 2 + noise(seed, time) * 8
            end
        when "late_bloomer"
            if time < 30 
                base + noise(seed, time) * 5
            else
                base + (time - 30) * 8 + Math.sin(time * 0.8 + seed) * 15
            end
        when "fake_out"
            if time < 15
                base + time * 2 + noise(seed, time) * 8
            else
                base - (time - 15) * 1.5 + Math.sin(time * 1.2 + seed) * 12
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