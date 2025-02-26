package com.tapresearch.kotlinsdk.preview.domain.use_case.get_surveys

import com.tapresearch.kotlinsdk.preview.common.Resource
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.models.TRSurvey
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

class SurveysUseCase @Inject constructor() {

    operator fun invoke(placementTag: String) : Flow<Resource<List<TRSurvey>>> = channelFlow {
        try {
            send(Resource.Loading())
            val list = TapResearch.getSurveysForPlacement(placementTag) { error ->
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        send(Resource.Error(message = "$error"))
                    }catch (ignored: Throwable){}
                }
            }
            if (!list.isNullOrEmpty())
                send(Resource.Success(list))
            else
                send(Resource.Error(message = "No surveys for $placementTag"))
        } catch (e: Exception) {
            send(Resource.Error(message = "Unexpected Exception occurred: "+e.localizedMessage))
        }
    }
}
