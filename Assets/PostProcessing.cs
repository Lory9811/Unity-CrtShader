using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Unity.VisualScripting.Member;

public class PostProcessing : MonoBehaviour {
    private Material crtSubpixels;
    private Material gaussianBlur;
    private Material bloom;
    private new Camera camera;

    // TODO: reorder blur RTs
    // (split in parallel arrays: tmp and stage output?)
    private RenderTexture[] blurTextures;
    private RenderTexture[] hBlurTextures;
    private int blurPasses;

    private RenderTexture crtTexture;

    void InitBlur(int passes, int kernelSize) {
        blurPasses = passes;

        gaussianBlur = new Material(Shader.Find("Hidden/GaussianBlur"));
        blurTextures = new RenderTexture[blurPasses];
        hBlurTextures = new RenderTexture[blurPasses];

        for (int i = 0; i < blurPasses; i++) {
            if (blurTextures[i] is not null) {
                blurTextures[i].Release();
            }
            if (hBlurTextures[i] is not null) {
                hBlurTextures[i].Release();
            }

            blurTextures[i] = new RenderTexture(Screen.width / (2 * (i + 1)), Screen.height / (2 * (i + 1)), 0);
            hBlurTextures[i] = new RenderTexture(Screen.width / (2 * (i + 1)), Screen.height / (2 * (i + 1)), 0);
        }
    }

    void InitCrt() {
        crtSubpixels = new Material(Shader.Find("Hidden/CrtEffect"));
        crtSubpixels.SetInteger("_ScreenWidth", Screen.width);
        crtSubpixels.SetInteger("_ScreenHeight", Screen.height);
        crtTexture = new RenderTexture(Screen.width, Screen.height, 0);
    }

    void Awake() {
        Application.targetFrameRate = 0;

        InitCrt();
        InitBlur(4, 7);
        bloom = new Material(Shader.Find("Hidden/Bloom"));

        camera = GetComponent<Camera>();
    }
    
    void BlurPass(RenderTexture source, RenderTexture destination, RenderTexture tmp) {
        gaussianBlur.SetInteger("_TextureSizeX", source.width);
        gaussianBlur.SetInteger("_TextureSizeY", source.height);
        Graphics.Blit(source, tmp, gaussianBlur, 0);
        Graphics.Blit(tmp, destination, gaussianBlur, 1);
    }

    void Blur(RenderTexture source, RenderTexture destination) {
        BlurPass(source, blurTextures[0], hBlurTextures[0]);

        if (blurPasses == 1) {
            return;
        }

        for (int i = 1; i < blurPasses - 1; i++) {
            BlurPass(blurTextures[i - 1], blurTextures[i], hBlurTextures[i]);
        }

        BlurPass(blurTextures[blurPasses - 2], destination, hBlurTextures[blurPasses - 1]);
    }

    void Bloom(RenderTexture source, RenderTexture blurred, RenderTexture destination) {
        bloom.SetTexture("_Blurred", blurred);
        Graphics.Blit(source, destination, bloom);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        RenderTexture active = RenderTexture.active;
        
        Graphics.Blit(source, crtTexture, crtSubpixels);

        Blur(source, blurTextures[blurPasses - 1]);

        Bloom(crtTexture, blurTextures[blurPasses - 1], destination);

        RenderTexture.active = active;
    }
}
