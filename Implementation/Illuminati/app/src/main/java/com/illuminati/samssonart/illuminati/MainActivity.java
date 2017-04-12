package com.illuminati.samssonart.illuminati;

import org.artoolkit.ar.base.ARActivity;
import org.artoolkit.ar.base.rendering.ARRenderer;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.FrameLayout;

public class MainActivity extends ARActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    private NativeRenderer nativeRenderer = new NativeRenderer();

    public native String stringFromJNI();
    public native String sliderChanged(float f);
    //public JavaCameraView javaCameraView;

    private SeekBar zAxisBar;
    private TextView tv;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        zAxisBar = (SeekBar) findViewById(R.id.seekBar);
        tv = (TextView) findViewById(R.id.textView) ;

        zAxisBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // TODO Auto-generated method stub
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // TODO Auto-generated method stub
            }

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {


                tv.setText(sliderChanged(progress/255.0f));

            }

        });
    }

    @Override
    protected ARRenderer supplyRenderer()
    {
        return nativeRenderer;
    }

    @Override
    protected FrameLayout supplyFrameLayout()
    {
        return (FrameLayout) this.findViewById(R.id.mainLayout);

    }
}
