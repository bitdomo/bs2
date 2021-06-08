#==============================================================================
# ■ RGSS3 特定スキル無効化特徴 Ver2.01　by 星潟
#------------------------------------------------------------------------------
# このスクリプトを導入することで
# 特定スキル及び通常攻撃を一定確率で無効化する特徴を
# 作成する事ができるようになります。 
# 特徴を設定できる物（装備品・ステート・アクター・職業・エネミー）の
# メモ欄に<スキル無効:X,Y>とする事で効果を発揮します。
#（Xの場所にスキルID、Yの場所に無効化確率を記入します）
# また、装備とステート等、複数の場所に同じスキルに対する無効化が設定してある場合
# それぞれの確率が加算された確率で無効化判定を行います。
#==============================================================================
# ★設定例（特徴を有する項目のメモ欄に記入）
#------------------------------------------------------------------------------
# <スキル無効:1>
# 
# 100％の確率でID1のスキルを無効化。
#------------------------------------------------------------------------------
# <スキル無効:1,75>
# 
# 75％の確率でID1のスキルを無効化。
#------------------------------------------------------------------------------
# <スキル無効:5,50>
# 
# 50％の確率でID5のスキルを無効化。
#------------------------------------------------------------------------------
# <スキル無効:127,100>
# 
# 100％の確率でID127のスキルを無効化。
#------------------------------------------------------------------------------
# <スキル無効:10,$game_variables[1]>
# 
# 変数1の値％の確率でID10のスキルを無効化。
#------------------------------------------------------------------------------
# <スキル無効:50,self.tp>
# 
# TPの値％の確率でID50のスキルを無効化。
#==============================================================================
# Ver1.01
# 同じ記述を繰り返す事で複数スキルを無効化できるように変更。
# Ver2.00
# 注釈を全面的に追加。
# キャッシュ化による軽量化を実施。
# 無効確率にスクリプトによる計算を行えるように変更。
#==============================================================================
module SKILL_CANCEL
  
  #スキル無効設定用キーワードを指定します。
  
  WORD = "スキル無効"
  
  #アクターが効果を無効化した際の名前に続くテキストを指定。
  
  TEXT1 = "への効果をかき消した！"
  
  #エネミーが効果を無効化した際の名前に続くテキストを指定。
  
  TEXT2 = "への効果がかき消された！"

end
class Game_Battler
  #--------------------------------------------------------------------------
  # スキルの個別無効化判定
  #--------------------------------------------------------------------------
  def skill_cancel?(skill_id)
    
    #特徴別に無効化率を計算し、合計した値を持って判定。
    
    feature_objects.inject(0) {|result, f| 
    v = f.skill_cancel[skill_id]
    result += v ? eval(v) : 0} > rand(100)
  
  end
  #--------------------------------------------------------------------------
  # スキルの効果適用
  #--------------------------------------------------------------------------
  alias item_apply_skill_cancel item_apply
  def item_apply(user, item)
    
    #使用しようとしているのがスキルであり、なおかつキャンセル出来る場合は
    #結果を消去し、使用フラグを立て、成功フラグを操作する。
    
    if item.is_a?(RPG::Skill) && self.skill_cancel?(item.id)
      @result.clear;@result.used = true;@result.success = !item.damage.none?;@result.cancel = true
      return
    end
    
    #本来の処理を実行する。
    
    item_apply_skill_cancel(user, item)
    
  end
end
class Game_ActionResult
  attr_accessor :cancel
  #--------------------------------------------------------------------------
  # 命中系フラグのクリア
  #--------------------------------------------------------------------------
  alias clear_hit_flags_skill_cancel clear_hit_flags
  def clear_hit_flags
    
    #本来の処理を実行。
    
    clear_hit_flags_skill_cancel
    
    #キャンセルフラグを初期化する。
    
    @cancel = false
    
  end
end
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # クリティカルの表示
  #--------------------------------------------------------------------------
  alias display_critical_skill_cancel display_critical
  def display_critical(target, item)
    
    #キャンセルの表示を実行。
    
    display_sc(target, item)
    
    #本来の処理を実行。
    
    display_critical_skill_cancel(target, item)
    
  end
  #--------------------------------------------------------------------------
  # キャンセルの表示
  #--------------------------------------------------------------------------
  def display_sc(target, item)
    
    #キャンセルが有効な場合はキャンセルの文章を表示。
    
    if target.result.cancel
      add_text(sprintf("%s" + (target.actor? ? SKILL_CANCEL::TEXT1 : SKILL_CANCEL::TEXT2), target.name))
      wait
    end
    
  end
end
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # キャンセル処理の値
  #--------------------------------------------------------------------------
  def skill_cancel
    
    #キャッシュが存在する場合はキャッシュを返す。
    
    @skill_cancel ||= create_skill_cancel
    
  end
  #--------------------------------------------------------------------------
  # キャンセル処理の値作成
  #--------------------------------------------------------------------------
  def create_skill_cancel
    
    #ハッシュを作成。
    
    h = {}
    
    #メモ欄からデータを取得する。
    
    note.each_line {|l|
    if /<#{SKILL_CANCEL::WORD}[：:](\S+)>/ =~ l
      a = $1.split(/\s*,\s*/)
      a.push("100") if a.size < 2
      h[a[0].to_i] = a[1]
    end}
    
    #ハッシュを返す。
    
    h
    
  end
end