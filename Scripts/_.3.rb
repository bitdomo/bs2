=begin

 ▼ イベント処理改善 ver. 3.0
 
 RPGツクールVXAce用スクリプト
 
 制作 : 木星ペンギン
 URL  : http://woodpenguin.blog.fc2.com/

------------------------------------------------------------------------------
 概要

 □ イベント処理を軽量化したり、使いやすい機能を実装します。

------------------------------------------------------------------------------
 使い方
 
 □ 更新を行わないスイッチと変数の番号設定
 
  ・設定した番号のスイッチや変数を操作しても、イベントの更新を行いません。
  
  ・セルフ変数と併用できます。
  　併用する場合はこちらを上にしてください。
  
  
 □ 別ページの実行内容を呼び出す
 
   ・イベントコマンドのスクリプトで
   　call_page(n) と入れることで n ページ目の実行内容を呼び出します。
   　コモンイベント呼び出しと同じ処理で呼び出します。
   
   ・一つのイベントを複数のページに分解できるため、管理がしやすくなります。
  
   ・ページが違っても同じ内容を呼び出すようにすることで、編集が楽になります。
 
   
 □ 他、細かな計量化
 
  ・コモンイベントの呼び出しで、余計なファバーを作成しないように修正
 
=end

module WdTk
module EvEX
#//////////////////////////////////////////////////////////////////////////////
#
# 設定項目
#
#//////////////////////////////////////////////////////////////////////////////
  #--------------------------------------------------------------------------
  # ● 更新しないスイッチ番号の配列
  #--------------------------------------------------------------------------
  Static_Switches = []
  
  #--------------------------------------------------------------------------
  # ● 更新しない変数番号の配列
  #     セルフ変数もここに入れてください。
  #--------------------------------------------------------------------------
  Static_Variables = []
  
end

#//////////////////////////////////////////////////////////////////////////////
#
# 以降、変更する必要なし
#
#//////////////////////////////////////////////////////////////////////////////

  @material ||= []
  @material << :EvEX
  def self.include?(sym)
    @material.include?(sym)
  end
  
end

#==============================================================================
# ■ Game_Switches
#==============================================================================
class Game_Switches
  #--------------------------------------------------------------------------
  # ☆ スイッチの設定
  #--------------------------------------------------------------------------
  def []=(switch_id, value)
    @data[switch_id] = value
    on_change unless WdTk::EvEX::Static_Switches.include?(switch_id)
  end
end

#==============================================================================
# ■ Game_Variables
#==============================================================================
class Game_Variables
  #--------------------------------------------------------------------------
  # ☆ 変数の設定
  #--------------------------------------------------------------------------
  def []=(variable_id, value)
    @data[variable_id] = value
    on_change unless WdTk::EvEX::Static_Variables.include?(variable_id)
  end
end

#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● イベントページの取得
  #--------------------------------------------------------------------------
  def get_page(index)
    index >= 0 ? @event.pages[index] : nil
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ◯ ファイバーの作成
  #--------------------------------------------------------------------------
  alias _wdtk_event_create_fiber create_fiber
  def create_fiber
    _wdtk_event_create_fiber if @depth == 0
  end
  #--------------------------------------------------------------------------
  # ● ページ呼び出し
  #--------------------------------------------------------------------------
  def call_page(index)
    # 別のページをコモンイベントのように呼び出す
    event = get_character(0)
    page = event ? event.get_page(index - 1) : nil
    if page
      @child = Game_Interpreter.new(@depth + 1)
      @child.setup(page.list, same_map? ? @event_id : 0)
      @child.run
      @child = nil
    end
  end
end