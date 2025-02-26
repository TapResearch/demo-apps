package com.tapresearch.tapresearchkotlindemo.preview.domain.use_case.get_surveys

import com.tapresearch.tapresearchkotlindemo.preview.common.Resource
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.models.TRSurvey
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import javax.inject.Inject

class SurveysUseCase @Inject constructor() {

    operator fun invoke(placementTag: String) : Flow<Resource<List<TRSurvey>>> = flow {
        try {
            emit(Resource.Loading())
            val list = TapResearch.getSurveysForPlacement(placementTag) { error ->
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        emit(Resource.Error(message = "$error"))
                    }catch (ignored: Throwable){}
                }
            }
            if (!list.isNullOrEmpty())
                emit(Resource.Success(list))
            else
                emit(Resource.Error(message = "No surveys for $placementTag"))
        } catch (e: Exception) {
            emit(Resource.Error(message = "Unexpected Exception occurred: "+e.localizedMessage))
        }
    }
}
