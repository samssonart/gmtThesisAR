package com.illuminati.samssonart.illuminati;

import org.artoolkit.ar.base.ARActivity;
import org.artoolkit.ar.base.rendering.ARRenderer;

import android.os.Bundle;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.FrameLayout;

public class MainActivity extends ARActivity {


    private NativeRenderer nativeRenderer = new NativeRenderer();
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


                tv.setText(nativeRenderer.sliderChanged(progress/255.0f));

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
