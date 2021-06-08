#==============================================================================
# ■ RGSS3 防御状態無視 Ver2.00 by 星潟
#------------------------------------------------------------------------------
# スキルやアイテムによるダメージが防御状態を無視するように設定できます。
#==============================================================================
# 設定例
#------------------------------------------------------------------------------
# スキルに防御状態無視率を設定したい場合（スキルのメモ欄に記入）
#------------------------------------------------------------------------------
# <防御状態無視率:50>
# 
# このように記入した場合、このスキルによるダメージは
# 50％の確率で敵の防御状態を無視します。
#------------------------------------------------------------------------------
# <防御状態無視率:$game_variables[1]>
# 
# このように記入した場合、このスキルによるダメージは
# 変数1の値％の確率で敵の防御状態を無視します。
#------------------------------------------------------------------------------
# 特徴を有する項目に防御状態無視率を設定したい場合
# （ステート・装備・アクター・職業・エネミーのメモ欄に記入。
#   S_VALがtrueの場合はスキルのメモ欄に記入する事で
#   防御状態無視のパッシブスキル化）
#------------------------------------------------------------------------------
# <パッシブ防御状態無視率:25>
# 
# このように記入した場合、この特徴を持つキャラクターは
# 25％の確率で敵の防御状態を無視するようになります。
#------------------------------------------------------------------------------
# <パッシブ防御状態無視率:user.mp_rate*100>
# 
# このように記入した場合、この特徴を持つキャラクターは
# MP割合の値％の確率で敵の防御状態を無視するようになります。
#==============================================================================
# Ver1.01 説明文を追加。
# Ver2.00 注釈を追加。
#         キャッシュ化による軽量化を実施。
#         無視率設定にスクリプトが使用できるように変更。
#==============================================================================
module V_GUARD

  #ステート・装備・アクター・職業・エネミーの
  #メモ欄に記述するパッシブ防御状態無視率のキーワードを設定します。
  
  VGW1 = "パッシブ防御状態無視率"
  
  #スキルのメモ欄に記述するスキル固有の防御状態無視率のキーワードを設定します。

  VGW2 = "防御状態無視率"
  
  #特徴を有するものだけでなく、スキルも読み込みます。
  #これにより、防御状態無視のパッシブスキルの作成が可能になります。
  #（ただし、その分読み込み負荷がかかります）
  
  S_VAL = true

end
class Game_Temp
  attr_accessor :vg_user_data
  attr_accessor :vg_user_item
end
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ダメージ計算
  #--------------------------------------------------------------------------
  alias make_damage_value_void_guard make_damage_value
  def make_damage_value(user, item)
    
    #使用者とアイテム/スキルの情報を保存する。
    
    void_guard_set(user, item)
    
    #本来の処理を実行。
    
    make_damage_value_void_guard(user, item)
    
    #保存しておいた使用者とアイテム/スキルの情報を削除する。
    
    void_guard_set(nil, nil)
    
  end
  #--------------------------------------------------------------------------
  # 防御の判定
  #--------------------------------------------------------------------------
  alias guard_void_guard? guard?
  def guard?
    
    #保存しておいた使用者とアイテム/スキルの情報を元に
    #防御状態の判定を行う。
    
    void_guard_check($game_temp.vg_user_data, $game_temp.vg_user_item) ? false : guard_void_guard?
    
  end
  #--------------------------------------------------------------------------
  # 防御状態無視判定
  #--------------------------------------------------------------------------
  def void_guard_check(user, item)
    
    #使用者もしくはアイテム/スキルの情報が存在しない場合はfalseを返す。
    
    return false if !user or !item
    
    #各特徴のデータを防御状態無視率を合計する。
    
    pec = user.feature_objects.inject(0) {|result, f| result += eval(f.f_void_guard_rate)}
    
    #アイテム/スキルの防御状態無視率を加算する。
    
    pec += eval(item.is_void_guard_rate)
    
    #パッシブスキルが有効な場合、各スキル別のパッシブ防御状態無視率を加算する。
    
    pec += user.skills.inject(0) {|result, s| result += eval(s.f_void_guard_rate)} if user.actor? && V_GUARD::S_VAL
    
    #防御状態無視率で最終的な判定を行う。
    
    pec > rand(100)
    
  end
  #--------------------------------------------------------------------------
  # 防御無視設定
  #--------------------------------------------------------------------------
  def void_guard_set(user, item)
    
    #使用者とアイテム/スキルの情報を更新する。
    
    $game_temp.vg_user_data = user
    $game_temp.vg_user_item = item
    
  end
end
class RPG::BaseItem
  def f_void_guard_rate
    
    #キャッシュが存在する場合はキャッシュを返す。
    
    return @f_void_guard_rate if @f_void_guard_rate
    
    #メモ欄からデータを取得する。
    
    memo = @note.scan(/<#{V_GUARD::VGW1}[：:](\S+)>/).flatten
    
    #正常なデータを取得できた場合はそのデータを。そうでない場合は"0"とする。
    
    @f_void_guard_rate = memo != nil && !memo.empty? ? memo[0] : "0"
    
    #データ返す。
    
    @f_void_guard_rate
    
  end
end
class RPG::UsableItem < RPG::BaseItem
  def is_void_guard_rate
    
    #キャッシュが存在する場合はキャッシュを返す。
    
    return @is_void_guard_rate if @is_void_guard_rate
    
    #メモ欄からデータを取得する。
    
    memo = @note.scan(/<#{V_GUARD::VGW2}[：:](\S+)>/).flatten
    
    #正常なデータを取得できた場合はそのデータを。そうでない場合は"0"とする。
    
    @is_void_guard_rate = memo != nil && !memo.empty? ? memo[0] : "0"
    
    #データ返す。
    
    @is_void_guard_rate
    
  end
end