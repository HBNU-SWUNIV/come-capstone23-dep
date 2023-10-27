package com.wit.example;

import androidx.appcompat.app.AppCompatActivity;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.media.Image;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.wit.witsdk.modular.sensor.device.exceptions.OpenDeviceException;
import com.wit.witsdk.modular.sensor.example.ble5.Bwt901ble;
import com.wit.witsdk.modular.sensor.example.ble5.interfaces.IBwt901bleRecordObserver;
import com.wit.witsdk.modular.sensor.modular.connector.modular.bluetooth.BluetoothBLE;
import com.wit.witsdk.modular.sensor.modular.connector.modular.bluetooth.BluetoothSPP;
import com.wit.witsdk.modular.sensor.modular.connector.modular.bluetooth.WitBluetoothManager;
import com.wit.witsdk.modular.sensor.modular.connector.modular.bluetooth.exceptions.BluetoothBLEException;
import com.wit.witsdk.modular.sensor.modular.connector.modular.bluetooth.interfaces.IBluetoothFoundObserver;
import com.wit.witsdk.modular.sensor.modular.processor.constant.WitSensorKey;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.io.*;

/**
 * Function: main interface
 * Explanation：
 * 1. This program is an example base on Bluetooth 5.0sdk developed by WitMotion
 * 2. This program is applicable to the following products of WitMotion
 * BWT901BLECL5.0
 * BWT901BLE5.0
 * WT901BLE5.0
 * 3. This program has only one page and no other pages
 *
 * @author huangyajun
 * @date 2022/6/29 11:35
 */
public class MainActivity extends AppCompatActivity implements IBluetoothFoundObserver, IBwt901bleRecordObserver {

    /**
     * log tag
     */
    private static final String TAG = "MainActivity";

    /**
     * Device List
     */
    private List<Bwt901ble> bwt901bleList = new ArrayList<>();

    /**
     * Controls whether the auto-refresh thread works
     */
    private boolean destroyed = true;

    /**
     * activity when created
     *
     * @author huangyajun
     * @date 2022/6/29 8:43
     */

    final static String foldername = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() +"/File";
    final static String filename = "file.txt";

    private List<String> fileList = new ArrayList<>();
    private ListView listView;
    private TextView fileContentTextView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        listView = findViewById(R.id.listView);
        fileContentTextView = findViewById(R.id.fileContentTextView);


        TabHost tabHost = findViewById(R.id.tabhost);
        tabHost.setup();

        TabHost.TabSpec tabSpec = tabHost.newTabSpec("메인").setIndicator("메인");
        tabSpec.setContent(R.id.메인);
        tabHost.addTab(tabSpec);

        TabHost.TabSpec tabSpec2 = tabHost.newTabSpec("기록").setIndicator("기록");
        tabSpec2.setContent(R.id.기록);
        tabHost.addTab(tabSpec2);


        // Initialize the Bluetooth manager, here will apply for Bluetooth permissions
        WitBluetoothManager.initInstance(this);

        // start search button
        Button startSearchButton = findViewById(R.id.startSearchButton);
        startSearchButton.setOnClickListener((v) -> {
            startDiscovery();
        });

        listView.setOnItemClickListener((adapterView, view, position, id) -> {
            String fileName = fileList.get(position);
            String filePath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS+"File") + File.separator + fileName;
            displayFileContent(filePath);
        });



/*
        // stop search button
        Button stopSearchButton = findViewById(R.id.stopSearchButton);
        stopSearchButton.setOnClickListener((v) -> {
            stopDiscovery();
        });

        // Acceleration calibration button
        Button appliedCalibrationButton = findViewById(R.id.appliedCalibrationButton);
        appliedCalibrationButton.setOnClickListener((v) -> {
            handleAppliedCalibration();
        });

        // Start Magnetic Field Calibration button
        Button startFieldCalibrationButton = findViewById(R.id.startFieldCalibrationButton);
        startFieldCalibrationButton.setOnClickListener((v) -> {
            handleStartFieldCalibration();
        });

        // End Magnetic Field Calibration button
        Button endFieldCalibrationButton = findViewById(R.id.endFieldCalibrationButton);
        endFieldCalibrationButton.setOnClickListener((v) -> {
            handleEndFieldCalibration();
        });

        // Read 03 register button
        Button readReg03Button = findViewById(R.id.readReg03Button);
        readReg03Button.setOnClickListener((v) -> {
            handleReadReg03();
        });
*/
        // Auto refresh data thread
        Thread thread = new Thread(this::refreshDataTh);
        destroyed = false;
        thread.start();
    }
//파일 쓰기
    public void WriteTextFile(String foldername, String filename, String contents){

        try{

            // foldername 경로의 파일 객체 생성 (디렉토리를 가리키고 있고, 해당 경로에 디렉토리가 없어도 File 객체 생성됨.)
            File dir = new File (foldername);

            //디렉토리 폴더가 없으면 생성함
            if(!dir.exists()){
                // 디렉토리 생성.
                // 만들고자 하는 디렉토리의 상위 디렉토리가 존재하지 않을 경우, 생성 불가
                dir.mkdir();
            }

            // 생성한 FileOutputStream 객체를 통해 파일을 생성, 내용 작성한다.
            // 기존 파일에 내용을 추가 할려면 두번째 인자로 true를 적어 준다. true를 추가해도 없으면 만든다.
            FileOutputStream fos = new FileOutputStream(foldername+"/"+filename, true);

            // 문자열을 바이트배열로 변환해서 파일에 저장한다.
            fos.write(contents.getBytes());

            // 파일 닫기.
            fos.close();

        }catch (IOException e){
            e.printStackTrace();
        }
    }

    private void loadFiles() {
        File downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS+"/File");
        File[] files = downloadDir.listFiles();

        if (files != null) {
            for (File file : files) {
                if (file.isFile() && file.getName().endsWith(".txt")) {
                    fileList.add(file.getName());
                }
            }
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, fileList);
        listView.setAdapter(adapter);
    }

    private void displayFileContent(String filePath) {
        try {
            BufferedReader reader = new BufferedReader(new FileReader(filePath));
            StringBuilder content = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
            reader.close();

            fileContentTextView.setText(content.toString());
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(this, "파일을 읽을 수 없습니다.", Toast.LENGTH_SHORT).show();
        }
    }
    /**
     * activity perish
     *
     * @author huangyajun
     * @date 2022/6/29 13:59
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();

    }

    /**
     * Start searching for devices
     *
     * @author huangyajun
     * @date 2022/6/29 10:04
     */
    public void startDiscovery() {

        // Turn off all device
        for (int i = 0; i < bwt901bleList.size(); i++) {
            Bwt901ble bwt901ble = bwt901bleList.get(i);
            bwt901ble.removeRecordObserver(this);
            bwt901ble.close();
        }

        // Erase all devices
        bwt901bleList.clear();

        // Start searching for bluetooth
        try {
            // get bluetooth manager
            WitBluetoothManager bluetoothManager = WitBluetoothManager.getInstance();
            // Monitor communication signals
            bluetoothManager.registerObserver(this);
            // start search
            bluetoothManager.startDiscovery();
        } catch (BluetoothBLEException e) {
            e.printStackTrace();
        }
    }

    /**
     * Stop searching for devices
     *
     * @author huangyajun
     * @date 2022/6/29 10:04
     */
    public void stopDiscovery() {
        // stop searching for bluetooth
        try {
            // acquire Bluetooth manager
            WitBluetoothManager bluetoothManager = WitBluetoothManager.getInstance();
            // Cancel monitor communication signals
            bluetoothManager.removeObserver(this);
            // stop searching
            bluetoothManager.stopDiscovery();
        } catch (BluetoothBLEException e) {
            e.printStackTrace();
        }
    }

    /**
     * This method will be called back when a Bluetooth 5.0 device is found
     *
     * @author huangyajun
     * @date 2022/6/29 8:46
     */
    @Override
    public void onFoundBle(BluetoothBLE bluetoothBLE) {
        // Create a Bluetooth 5.0 sensor connection object
        Bwt901ble bwt901ble = new Bwt901ble(bluetoothBLE);
        // add to device list
        bwt901bleList.add(bwt901ble);

        // Registration data record
        bwt901ble.registerRecordObserver(this);

        // Turn on the device
        try {
            bwt901ble.open();
        } catch (OpenDeviceException e) {
            // Failed to open device
            e.printStackTrace();
        }
    }

    /**
     * This method will be called back when a Bluetooth 2.0 device is found
     *
     * @author huangyajun
     * @date 2022/6/29 10:01
     */
    @Override
    public void onFoundSPP(BluetoothSPP bluetoothSPP) {
        // Without doing any processing, this sample program only demonstrates how to connect a Bluetooth 5.0 device
    }

    /**
     * This method will be called back when data needs to be recorded
     *
     * @author huangyajun
     * @date 2022/6/29 8:46
     */
    @Override
    public void onRecord(Bwt901ble bwt901ble) {
        String deviceData = getDeviceData(bwt901ble);
        Log.d(TAG, "device data [ " + bwt901ble.getDeviceName() + "] = " + deviceData);
    }

    /**
     *Auto refresh data thread
     *
     * @author huangyajun
     * @date 2022/6/29 13:41
     */
    private void refreshDataTh() {

        Bwt901ble bwt901ble;

        Double datax = 0.0;
        int flag = 1;
        String str = null;
        int[] images = {R.drawable.my1,R.drawable.my2,R.drawable.my3};

        while (!destroyed) {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }


            StringBuilder text = new StringBuilder();
            for (int i = 0; i < bwt901bleList.size(); i++) {
                // Make all devices accelerometer calibrated
                bwt901ble = bwt901bleList.get(i);
                String deviceData = getDeviceData(bwt901ble);
                text.append(deviceData);

                str = bwt901ble.getDeviceData(WitSensorKey.AngleX);

                if (str != null) {
                    try {
                        datax = Double.parseDouble(str);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }


                TextView deviceDataTextView = findViewById(R.id.deviceDataTextView);
                ImageView imageView = (ImageView) findViewById(R.id.imageView);

                if (datax > -5 && datax < 5) flag = 0;
                else if (datax < -5) flag = 1;
                else if (datax > 5) flag = 2;


                int finalFlagg = flag;
                Bwt901ble finalBwt901ble = bwt901ble;
                runOnUiThread(() -> {
                    deviceDataTextView.setText(text.toString());
                    imageView.setImageResource(images[finalFlagg]);


                    // Make all devices accelerometer calibrated

                    String xdata = finalBwt901ble.getDeviceData(WitSensorKey.AngleX);
                    // 파일 작성시간 (현재시간으로)
                    String now = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
                    // 파일 내용 생성
                    String contents = "파일 내용 :"+ xdata + " \n 파일 작성 시간 : " + now + "\n";
                    // 파일 없으면 생성 후 파일안에 내용 저장.
                    WriteTextFile(foldername, filename, contents);

                    loadFiles();



                });
            }
        }
    }
    /**
     * Get a device's data
     *
     * @author huangyajun
     * @date 2022/6/29 11:37
     */
    private String getDeviceData(Bwt901ble bwt901ble) {
        StringBuilder builder = new StringBuilder();
       // builder.append(bwt901ble.getDeviceName()).append("\n");
        builder.append(getString(R.string.accX)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AccX)).append("g \t");
        builder.append(getString(R.string.accY)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AccY)).append("g \t");
        builder.append(getString(R.string.accZ)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AccZ)).append("g \n");
       /* builder.append(getString(R.string.asX)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AsX)).append("°/s \t");
        builder.append(getString(R.string.asY)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AsY)).append("°/s \t");
        builder.append(getString(R.string.asZ)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AsZ)).append("°/s \n");
        builder.append(getString(R.string.angleX)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AngleX)).append("° \t");
        builder.append(getString(R.string.angleY)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AngleY)).append("° \t");
        builder.append(getString(R.string.angleZ)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.AngleZ)).append("° \n");
        builder.append(getString(R.string.hX)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.HX)).append("\t");
        builder.append(getString(R.string.hY)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.HY)).append("\t");
        builder.append(getString(R.string.hZ)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.HZ)).append("\n");
        builder.append(getString(R.string.t)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.T)).append("\n");
        builder.append(getString(R.string.electricQuantityPercentage)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.ElectricQuantityPercentage)).append("\n");
        builder.append(getString(R.string.versionNumber)).append(":").append(bwt901ble.getDeviceData(WitSensorKey.VersionNumber)).append("\n");*/
        return builder.toString();
    }

    /**
     * Make all devices accelerometer calibrated
     *
     * @author huangyajun
     * @date 2022/6/29 10:25
     */
    private void handleAppliedCalibration() {
        for (int i = 0; i < bwt901bleList.size(); i++) {
            Bwt901ble bwt901ble = bwt901bleList.get(i);
            // unlock register
            bwt901ble.unlockReg();
            // send command
            bwt901ble.appliedCalibration();
        }
        Toast.makeText(this, "OK", Toast.LENGTH_LONG).show();
    }

    /**
     * Let all devices begin magnetic field calibration
     *
     * @author huangyajun
     * @date 2022/6/29 10:25
     */
    private void handleStartFieldCalibration() {
        for (int i = 0; i < bwt901bleList.size(); i++) {
            Bwt901ble bwt901ble = bwt901bleList.get(i);
            // unlock register
            bwt901ble.unlockReg();
            // send command
            bwt901ble.startFieldCalibration();
        }
        Toast.makeText(this, "OK", Toast.LENGTH_LONG).show();
    }

    /**
     * Let's all devices end the magnetic field calibration
     *
     * @author huangyajun
     * @date 2022/6/29 10:25
     */
    private void handleEndFieldCalibration() {
        for (int i = 0; i < bwt901bleList.size(); i++) {
            Bwt901ble bwt901ble = bwt901bleList.get(i);
            // unlock register
            bwt901ble.unlockReg();
            // send command
            bwt901ble.endFieldCalibration();
        }
        Toast.makeText(this, "OK", Toast.LENGTH_LONG).show();
    }

    /**
     * Let's all devices end the magnetic field calibration
     *
     * @author huangyajun
     * @date 2022/6/29 10:25
     */
    private void handleReadReg03() {
        for (int i = 0; i < bwt901bleList.size(); i++) {
            Bwt901ble bwt901ble = bwt901bleList.get(i);
            // Must be used sendProtocolData method, and the device will read the register value when you using this method
            int waitTime = 200;
            // The command to send the command, and wait 200ms
            bwt901ble.sendProtocolData(new byte[]{(byte) 0xff, (byte) 0xAA, (byte) 0x27, (byte) 0x03, (byte) 0x00}, waitTime);
            //get the value of register 03
            String reg03Value = bwt901ble.getDeviceData("03");
            // If it is read up, reg03Value is the value of the register. If it is not read up, you can enlarge waitTime, or read it several times.v
            Toast.makeText(this, bwt901ble.getDeviceName() + " reg03Value: " + reg03Value, Toast.LENGTH_LONG).show();
        }
    }
}