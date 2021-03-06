#==============================================================================
# ■ Game_Actors
#------------------------------------------------------------------------------
# 　アクターの配列のラッパーです。このクラスのインスタンスは $game_actors で参
# 照されます。
#==============================================================================

class Game_Actors
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● アクターの取得
  #--------------------------------------------------------------------------
  def [](actor_id)
    return nil unless $data_actors[actor_id]
    @data[actor_id] ||= Game_Actor.new(actor_id)
  end
end
