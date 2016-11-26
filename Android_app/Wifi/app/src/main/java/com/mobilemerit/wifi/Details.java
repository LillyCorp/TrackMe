package com.mobilemerit.wifi;

/**
 * Created by Iron_Man on 26/11/16.
 */
public class Details {

    private String name;
    private String ip;
    private String wifiname;

    public Details(String name, String ip,String wifiname)
    {
        this.name = name;
        this.ip = ip;
        this.wifiname = wifiname;
    }

    public String getName()
    {
        return this.name;
    }

    public String getIp()
    {
        return this.ip;
    }

    public String getWifiname()
    {
        return this.wifiname;
    }

}
