AGED_BRIE = 'Aged Brie'.freeze
BACKSTAGE_PASS = 'Backstage passes to a TAFKAL80ETC concert'.freeze
SULFURAS = 'Sulfuras, Hand of Ragnaros'.freeze
CONJURED = 'Conjured Mana Cake'.freeze

NORMAL_QUALITY_DELTA = -1

def quality_delta(item)
  case item.name
  when AGED_BRIE
    # "Aged Brie" actually increases in Quality the older it gets
    -NORMAL_QUALITY_DELTA
  when BACKSTAGE_PASS
    # "Backstage passes", like aged brie, increases in Quality as it's SellIn
    # value approaches; Quality increases by 2 when there are 10 days or less
    # and by 3 when there are 5 days or less but Quality drops to 0 after the
    # concert
    if item.sell_in <= 0
      -item.quality
    elsif item.sell_in <= 5
      3
    elsif item.sell_in <= 10
      2
    else
      -NORMAL_QUALITY_DELTA
    end
  when SULFURAS
    # "Sulfuras", being a legendary item, never has to be sold or decreases in
    # Quality
    0
  when CONJURED
    # "Conjured" items degrade in Quality twice as fast as normal items
    2 * NORMAL_QUALITY_DELTA
  else
    NORMAL_QUALITY_DELTA
  end
end

def sell_in_delta(item)
  if item.name == SULFURAS
    # "Sulfuras", being a legendary item, never has to be sold or decreases in
    # Quality
    0
  else
    -1
  end
end

def update_quality(items)
  items.each do |item|
    delta = quality_delta(item)
    if delta != 0
      # Once the sell by date has passed, Quality degrades twice as fast
      scale = item.sell_in <= 0 ? 2 : 1

      # The Quality of an item is never negative
      # The Quality of an item is never more than 50
      item.quality = (item.quality + scale * delta).clamp(0, 50)
    end
    item.sell_in += sell_in_delta(item)
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

