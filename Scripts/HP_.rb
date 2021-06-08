#==============================================================================
# ★ RGSS3_スキルコスト拡張 Ver1.3
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

スキルのメモ欄にタグを書き込むことでアイテム、ＨＰ、お金を
コストとして設定できるようになります。
  <消費アイテム 1>　…　１番のアイテムを１個消費
  <消費ＨＰ 50>　　 …　ＨＰを５０消費
  <消費ＨＰ 25%>    …　残りＨＰの２５％を消費
  <消費金額 100>　　…　お金を１００消費
  
ＭＰとＴＰの消費量を現在値に対する割合で設定することもできます。
消費量の下限値は 1 です。
　<消費ＭＰ 100%>   …　残りＭＰすべてを消費
　<消費ＴＰ 50%>    …　残りＴＰの半分を消費

ＨＰとＭＰの最大値、所持金に対する割合を設定するには以下のようにします。
  <消費最大ＨＰ 50%>  …　最大ＨＰの半分を消費
  <消費最大ＭＰ 100%> …　最大ＭＰのすべてを消費（満タンでないと使えない）
  <消費金額 5%>       …  所持金の５％を消費（下限値１）
  
=== 注意点 ===
  ＨＰコストを支払うことで戦闘不能になってしまうような状況では
  スキルを使用することができません。

2016.12.03  Ver1.3
  ・消費ＴＰ割合を設定した場合にコスト表示がおかしくなる不具合を修正
  ・ＨＰが 0 のときコスト支払いができないと判断されてしまう不具合を修正
  
2013.01.23  Ver1.2
  ・ＨＰとＭＰ、所持金の最大値に対する割合でコストを設定するタグを追加
  
2012.02.17  Ver1.11
  ・ＨＰの割合消費を追加
  ・ＭＰとＴＰのコストがともに０のとき、ＨＰコストを表示します
  
2012.02.14  Ver1.1
  ・ＭＰとＴＰの割合消費を追加
  
2011.12.15　Ver1.0
  公開

=end

$tmscripts = {} unless $tmscripts
$tmscripts["skcost"] = true

#==============================================================================
# ■ RPG::Skill
#==============================================================================
class RPG::Skill
  #--------------------------------------------------------------------------
  # ○ 消費アイテムを返す
  #--------------------------------------------------------------------------
  def item_cost
    /<消費アイテム\s*(\d+)\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費HPを返す
  #--------------------------------------------------------------------------
  def hp_cost
    /<消費(?:ＨＰ|HP)\s*(\d+)\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費金額を返す
  #--------------------------------------------------------------------------
  def gold_cost
    /<消費金額\s*(\d+)\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費所持金割合を返す
  #--------------------------------------------------------------------------
  def gold_cost_rate
    /<消費金額\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費HP割合を返す
  #--------------------------------------------------------------------------
  def hp_cost_rate
    /<消費(?:ＨＰ|HP)\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費最大HP割合を返す
  #--------------------------------------------------------------------------
  def mhp_cost_rate
    /<消費最大(?:ＨＰ|HP)\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費MP割合を返す
  #--------------------------------------------------------------------------
  def mp_cost_rate
    /<消費(?:ＭＰ|HP)\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費最大HP割合を返す
  #--------------------------------------------------------------------------
  def mmp_cost_rate
    /<消費最大(?:ＭＰ|MP)\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ○ 消費TP割合を返す
  #--------------------------------------------------------------------------
  def tp_cost_rate
    /<消費(?:ＴＰ|TP)\s*(\d+)\%\s*>/ =~ @note ? $1.to_i : 0
  end
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ スキルの消費 HP 計算
  #--------------------------------------------------------------------------
  def skill_hp_cost(skill)
    if skill.mhp_cost_rate > 0
      [self.mhp * skill.mhp_cost_rate / 100, 1].max
    elsif skill.hp_cost_rate > 0
      [self.hp * skill.hp_cost_rate / 100, 1].max
    else
      skill.hp_cost
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルの消費 MP 計算
  #--------------------------------------------------------------------------
  alias tmskcost_game_battlerbase_skill_mp_cost skill_mp_cost
  def skill_mp_cost(skill)
    if skill.mmp_cost_rate > 0
      [self.mmp * skill.mmp_cost_rate / 100, 1].max
    elsif skill.mp_cost_rate > 0
      [self.mp * skill.mp_cost_rate / 100, 1].max
    else
      tmskcost_game_battlerbase_skill_mp_cost(skill)
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルの消費 TP 計算
  #--------------------------------------------------------------------------
  alias tmskcost_game_battlerbase_skill_tp_cost skill_tp_cost
  def skill_tp_cost(skill)
    if skill.tp_cost_rate > 0
      [(self.tp * skill.tp_cost_rate).truncate / 100, 1].max
    else
      tmskcost_game_battlerbase_skill_tp_cost(skill)
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルの消費 金額 計算
  #--------------------------------------------------------------------------
  def skill_gold_cost(skill)
    result = skill.gold_cost
    if skill.gold_cost_rate > 0
      result += [$game_party.gold * skill.gold_cost_rate / 100, 1].max
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● スキル使用コストの支払い可能判定
  #--------------------------------------------------------------------------
  alias tmskcost_game_battlerbase_skill_cost_payable? skill_cost_payable?
  def skill_cost_payable?(skill)
    hp_cost = skill_hp_cost(skill)
    tmskcost_game_battlerbase_skill_cost_payable?(skill) &&
      (hp_cost <= 0 || @hp > hp_cost)
  end
  #--------------------------------------------------------------------------
  # ● スキル使用コストの支払い
  #--------------------------------------------------------------------------
  alias tmskcost_game_battlerbase_pay_skill_cost pay_skill_cost
  def pay_skill_cost(skill)
    tmskcost_game_battlerbase_pay_skill_cost(skill)
    self.hp -= skill_hp_cost(skill)
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # ● スキル使用コストの支払い可能判定
  #--------------------------------------------------------------------------
  alias tmskcost_game_actor_skill_cost_payable? skill_cost_payable?
  def skill_cost_payable?(skill)
    item = $data_items[skill.item_cost]
    tmskcost_game_actor_skill_cost_payable?(skill) &&
      (!item || $game_party.has_item?(item)) &&
      ($game_party.gold >= skill_gold_cost(skill))
  end
  #--------------------------------------------------------------------------
  # ● スキル使用コストの支払い
  #--------------------------------------------------------------------------
  alias tmskcost_game_actor_pay_skill_cost pay_skill_cost
  def pay_skill_cost(skill)
    tmskcost_game_actor_pay_skill_cost(skill)
    item = $data_items[skill.item_cost]
    $game_party.lose_item(item, 1) if item
    $game_party.lose_gold(skill_gold_cost(skill))
  end
end

#==============================================================================
# ■ Window_SkillList
#==============================================================================
class Window_SkillList
  #--------------------------------------------------------------------------
  # ● スキルの使用コストを描画
  #--------------------------------------------------------------------------
  alias tmskcost_window_skilllist_draw_skill_cost draw_skill_cost
  def draw_skill_cost(rect, skill)
    if @actor.skill_tp_cost(skill) > 0 || @actor.skill_mp_cost(skill) > 0
      tmskcost_window_skilllist_draw_skill_cost(rect, skill)
    elsif @actor.skill_hp_cost(skill) > 0
      change_color(hp_gauge_color2, enable?(skill))
      draw_text(rect, @actor.skill_hp_cost(skill), 2)
    end
  end
end

