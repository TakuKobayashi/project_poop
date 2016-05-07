/// <reference path="../source/ts/d_ts/jquery.d.ts" />
declare class Sherlock {
    private _APIKEY;
    private _availability;
    constructor();
    setAPI(service: string, credentials: any): void;
    checkAvailability(): void;
    recognize(text: string, lang?: string): any;
}
