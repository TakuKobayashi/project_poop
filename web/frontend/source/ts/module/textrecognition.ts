/// <reference path="../d_ts/jquery.d.ts" />

// text recognition

class Sherlock {
  private _APIKEY:any = {
    bluemix:{ url: "" , password: "" , username: ""  },
    docomo:null,
  }
  
  // セットアップ状況
  private _availability: any = {
    bluemix:false
  }
  
  constructor(){
  }

  setAPI(service:string,credentials:any){
    if(service === "bluemix"){
      this._APIKEY.bluemix = credentials;
      this._availability.bluemix = true;
    }
  }
  
  /**
   * APIの設定状況をチェック
   */
  checkAvailability(){
    
  }
  
  /**
   * 認識を実行
   */
  recognize( text:string, lang?:string ): any{
    const def = $.Deferred();
    
    
    return def;
    
  }
}

