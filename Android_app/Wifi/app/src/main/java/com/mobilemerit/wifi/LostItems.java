package com.mobilemerit.wifi;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.mobilemerit.javafiles.ImportDialog;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;

/**
 * Created by Iron_Man on 25/11/16.
 */
public class LostItems extends Activity {

    Button btn,btn2;
    final Context context = this;
    ArrayAdapter adapter;
    ListView listView;
    ArrayList<Details> items;
    String name,ip,namerem,wifiname;
    Details details;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.item_lost);

        listView = (ListView) findViewById(R.id.lostlist);
        items = new ArrayList<Details>();
        btn = (Button) findViewById(R.id.pushbtn);
        btn.setOnClickListener(new View.OnClickListener()
        {

            @Override
            public void onClick(View view) {


                AlertDialog.Builder alertDialog = new AlertDialog.Builder(LostItems.this);
                alertDialog.setTitle("Register Item");

                /*final EditText input = new EditText(LostItems.this);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,40);
                input.setLayoutParams(lp);
                alertDialog.setView(input);

                final EditText input1 = new EditText(LostItems.this);
                LinearLayout.LayoutParams lp1 = new LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,40);
                input1.setLayoutParams(lp1);
                alertDialog.setView(input1);*/

                LinearLayout layout = new LinearLayout(LostItems.this);
                layout.setOrientation(LinearLayout.VERTICAL);

                final EditText inputname = new EditText(LostItems.this);
                inputname.setHint("Enter object name");
                layout.addView(inputname);

                final EditText inputip = new EditText(LostItems.this);
                inputip.setHint("Enter ip");
                layout.addView(inputip);

                final EditText inputwifi = new EditText(LostItems.this);
                inputwifi.setHint("Enter wifi name");
                layout.addView(inputwifi);

                alertDialog.setView(layout);

                alertDialog.setPositiveButton("Done",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {

                                name = inputname.getText().toString();
                                ip = inputip.getText().toString();
                                wifiname = inputwifi.getText().toString();
                                details = new Details(name,ip,wifiname);
                                items.add(details);
                                dialog.dismiss();

                            }
                        });

                alertDialog.setNegativeButton("Cancel",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        });

                alertDialog.show();

                adapter = new ArrayAdapter(LostItems.this,R.layout.activity_list,R.id.listtext,items);
                listView.setAdapter(new customAdapter(items));
            }
        });

        btn2 = (Button) findViewById(R.id.ledbtn);
        btn2.setOnClickListener(new View.OnClickListener()
        {

            @Override
            public void onClick(View view) {

                /*String serverAdress = "10.10.2.150/";
                HttpRequestTask requestTask = new HttpRequestTask(serverAdress);
                requestTask.execute("1");

                Intent intent = new Intent(LostItems.this, MainActivity.class);
                startActivity(intent);*/

                AlertDialog.Builder alertDialog = new AlertDialog.Builder(LostItems.this);
                alertDialog.setTitle("Register Item");

                final EditText input = new EditText(LostItems.this);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
                input.setLayoutParams(lp);
                alertDialog.setView(input);

                alertDialog.setPositiveButton("Done",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {

                                namerem = input.getText().toString();
                                for(int i=0;i<items.size();i++)
                                {
                                    if(namerem.equalsIgnoreCase(items.get(i).getName()))
                                    {
                                        items.remove(i);
                                    }
                                }
                                dialog.dismiss();

                            }
                        });

                alertDialog.setNegativeButton("Cancel",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        });

                alertDialog.show();

                adapter = new ArrayAdapter(LostItems.this,R.layout.activity_list,R.id.listtext,items);
                listView.setAdapter(new customAdapter(items));

            }
        });

        adapter = new ArrayAdapter(LostItems.this,R.layout.activity_list,R.id.listtext,items);
        listView.setAdapter(new customAdapter(items));

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                String serverAdress = items.get(position).getIp()+"/";
                HttpRequestTask requestTask = new HttpRequestTask(serverAdress);
                requestTask.execute("1");

                Intent intent = new Intent(LostItems.this, MainActivity.class);
                intent.putExtra("wifin",items.get(position).getWifiname());
                startActivity(intent);

            }
        });

    }


    private class HttpRequestTask extends AsyncTask<String, Void, String> {

        private String serverAdress;
        private String serverResponse = "";
        private AlertDialog dialog;

        public HttpRequestTask(String serverAdress) {
            this.serverAdress = serverAdress;

            //dialog = new AlertDialog.Builder(context)
                    //.setTitle("HTTP Response from Ip Address:")
                    //.setCancelable(true)
                    //.create();
        }

        @Override
        protected String doInBackground(String... params) {
            //dialog.setMessage("Data sent , waiting response from server...");

            //if (!dialog.isShowing())
              //  dialog.show();

            String val = params[0];
            final String url = "http://" + serverAdress + "ON" + val;

            try {
                HttpClient client = new DefaultHttpClient();
                HttpGet getRequest = new HttpGet();
                getRequest.setURI(new URI(url));
                HttpResponse response = client.execute(getRequest);

                InputStream inputStream = null;
                inputStream = response.getEntity().getContent();
                BufferedReader bufferedReader =
                        new BufferedReader(new InputStreamReader(inputStream));

                serverResponse = bufferedReader.readLine();
                inputStream.close();

            } catch (URISyntaxException e) {
                e.printStackTrace();
                serverResponse = e.getMessage();
            } catch (ClientProtocolException e) {
                e.printStackTrace();
                serverResponse = e.getMessage();
            } catch (IOException e) {
                e.printStackTrace();
                serverResponse = e.getMessage();
            }

            return serverResponse;
        }

        @Override
        protected void onPostExecute(String s) {
            /*dialog.setMessage(serverResponse);

            if (!dialog.isShowing())
                dialog.show();*/
        }

        @Override
        protected void onPreExecute() {
            /*dialog.setMessage("Sending data to server, please wait...");

            if (!dialog.isShowing())
                dialog.show();*/
        }
    }


    private class customAdapter extends BaseAdapter{

        ArrayList<Details> marray;

        public customAdapter(ArrayList<Details> arr)
        {
            marray = arr;
        }

        @Override
        public int getCount() {
            return marray.size();
        }

        @Override
        public Object getItem(int position) {
            return marray.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int positon, View contentview, ViewGroup parent) {

            if(contentview == null)
            {
                contentview = getLayoutInflater().inflate(R.layout.activity_list,parent,false);
            }

            TextView textView = (TextView) contentview.findViewById(R.id.listtext);
            textView.setText(marray.get(positon).getName());

            return contentview;
        }
    }

}
