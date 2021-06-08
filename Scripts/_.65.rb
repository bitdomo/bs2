#==============================================================================
# ステートでスキル変化 ver1.00
#------------------------------------------------------------------------------
#[特徴]
# 特定のステートが付与されているとき、スキルが変化する。
#
#[仕様]
# スキルウィンドウに表示されるのは、元になるスキル。
# 使用条件は元になるスキルで判断される。
# 消費するMP/TPは変化後のスキル。使用時のメッセージも変化後のスキル。
# そのため、元になるスキルと変化後のスキルのスキルタイプ、消費MP/TPは同じにしてください。
#
#[スキル設定方法]
# スキルのメモ欄に <ステート変化:スキルID,ステートID> と書く。
# 複数書いた場合、条件を満たしたものの中で一番最後（下）に記述したものが反映されます。
# 例) <ステート変化:134,21>
#
#[注意]
# 『能力値でスキル変化』を導入している場合、
# このスクリプトはそれより下に導入してください。
#
#
# 作成：ぶちょー
# ホム：http://nyannyannyan.bake-neko.net/
# 著作：自分で作ったとか言わないで＞＜
#       改造はご自由にどうぞ。
#       リードミーとかに私の名前の載せたりするのは任意で。
#==============================================================================

#==============================================================================
# バージョンアップ情報
# ver1.00 公開
#==============================================================================

#==============================================================================
# 設定項目はありません
#==============================================================================

$kzr_imported = {} if $kzr_imported == nil
$kzr_imported["SkillChangeByState"] = true
#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :default_use_skill_id
  #--------------------------------------------------------------------------
  # ● スキルを設定
  #--------------------------------------------------------------------------
  alias kzr_skill_change_by_state_set_skill set_skill
  def set_skill(skill_id)
    @default_use_skill_id = skill_id
    kzr_skill_change_by_state_set_skill($data_skills[skill_id].skill_change_state(@subject, skill_id))
  end
end

#==============================================================================
# ■ RPG::Skill
#==============================================================================
class RPG::Skill < RPG::UsableItem
  def skill_change_state(a, id)
    $data_skills[id].note.each_line {|line|
    case line
    when /<ステート変化:(\d+),(\d+)>/ ; id = $1.to_i if a.state?($2.to_i)
    end
    }
    id
  end
end