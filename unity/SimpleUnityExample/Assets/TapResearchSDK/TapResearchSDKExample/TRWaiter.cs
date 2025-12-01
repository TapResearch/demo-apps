using UnityEngine;
using System;
using System.Collections;

public class TRWaiter : MonoBehaviour
{
    
    public void Wait(float waitTime, Action onComplete)
    {
        StartCoroutine(DoWait(waitTime, onComplete));
    }

    private IEnumerator DoWait(float waitTime, Action onComplete)
    {
        float elapsedTime = 0f;
 
        while (elapsedTime < waitTime)
        {
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        onComplete.Invoke();
    }

}
