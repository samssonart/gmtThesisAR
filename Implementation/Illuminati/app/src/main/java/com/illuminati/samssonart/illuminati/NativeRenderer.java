package com.illuminati.samssonart.illuminati;

import org.artoolkit.ar.base.FPSCounter;
import android.opengl.GLES20;

import org.artoolkit.ar.base.ARToolKit;
import org.artoolkit.ar.base.rendering.gles20.ARRendererGLES20;
import org.artoolkit.ar.base.rendering.gles20.CubeGLES20;
import org.artoolkit.ar.base.rendering.gles20.ShaderProgram;
import com.illuminati.samssonart.illuminati.shader.SimpleShaderProgram;
import com.illuminati.samssonart.illuminati.shader.SimpleVertexShader;
import com.illuminati.samssonart.illuminati.shader.SimpleFragmentShader;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;



public class NativeRenderer extends ARRendererGLES20
{

    static {
        System.loadLibrary("native-lib");
    }

    public native String sliderChanged(float f);

    private int markerID = -1;
    private CubeGLES20 cube;

    /**
     * This method gets called from the framework to setup the ARScene.
     * So this is the best spot to configure you assets for your AR app.
     * For example register used markers in here.
     */
    @Override
    public boolean configureARScene() {



        markerID = ARToolKit.getInstance().addMarker("single;Data/hiro.patt;80");
        if (markerID < 0) return false;

        return true;
    }

    //Shader calls should be within a GL thread that is onSurfaceChanged(), onSurfaceCreated() or onDrawFrame()
    //As the cube instantiates the shader during setShaderProgram call we need to create the cube here.
    @Override
    public void onSurfaceCreated(GL10 unused, EGLConfig config) {
        super.onSurfaceCreated(unused, config);

        ShaderProgram shaderProgram = new SimpleShaderProgram(new SimpleVertexShader(), new SimpleFragmentShader());
        cube = new CubeGLES20(40.0f, 0.0f, 0.0f, 20.0f);
        cube.setShaderProgram(shaderProgram);
    }

    @Override
    public void draw() {
        super.draw();

        GLES20.glEnable(GLES20.GL_CULL_FACE);
        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
        GLES20.glFrontFace(GLES20.GL_CW);

        float[] projectionMatrix = ARToolKit.getInstance().getProjectionMatrix();

        // If the marker is visible, apply its transformation, and render a cube
        if (ARToolKit.getInstance().queryMarkerVisible(markerID)) {
            cube.draw(projectionMatrix, ARToolKit.getInstance().queryMarkerTransformation(markerID));
        }
    }


}
