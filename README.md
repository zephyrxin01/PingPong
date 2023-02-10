# PingPong

## 遊戲操作說明: 
- 打開exe檔後，會隨機設定球彈射的方向，以及隨機淺藍色bonus球的位置。玩家需要透過板子將球接住，並且努力打到bonus球的位置。按下鍵盤w代表往上移動板子，s則代表往下移動板子。如果接住球或是打到bonus球會獲得1分，且bonus球被接住會重新出現在隨機的位置。如果板子沒有接到球則會扣掉生命值，並且reset初始彈射球的方向。 
## 程式Procedure簡介與實作: 
- MAIN:印出遊戲初始頁面、設定球一開始彈射方向 
- ResetRound:執行和main一樣的內容(當板子沒有打到球) 
- GameLoop: call Input、DrawPlayer、UpdateBall procedure 
- DrawPlayer:畫出板子、分數和生命值 
- Input:確認使用者輸入上下鍵、並call MoveUp、MoveDown  
- Updateball:清除原位置的球、判斷新位置球是否碰撞到物體 
- MoveUp、MoveDown確認板子沒有超過上下界 
- checkbonus: 確認打到加分球、call Bonusvanished並增加score 
- Bonusvanished:刪除舊的球、呼叫新的bonus球(Bonuscreate) 
- Bonus:產生新bonusball的隨機位置 

P.S.由於程式碼過多，詳細運作與記憶體呼叫...等等請看asm檔 

## demo截圖: 
![image](https://user-images.githubusercontent.com/69389836/217981736-28899645-daec-46e4-a56c-660d6e55c1d3.png) 
 
