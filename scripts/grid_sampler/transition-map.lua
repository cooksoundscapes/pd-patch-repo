return function(state)
    return {
        hard_sync = {
            note_in = {
                [state.off] = state.rec_cue,
                [state.stopped] = state.play_cue,
                [state.rec] = state.stop_rec_cue,
                [state.rec_cue] = state.off,
            },
            cue = {
                [state.stop_cue] = state.stopped,
                [state.rec_cue] = state.rec,
                [state.play_cue] = state.playing,
                [state.stop_rec_cue] = state.playing
            }
        },
        free = {
            note_in = {
                [state.off] = state.rec,
                [state.stopped] = state.playing,
                [state.playing] = state.playing,
                [state.rec] = state.playing,
            },
            cue = {}
        }
    }
end