//
// Created by gx on 23-11-23.
//

#include "timer.h"

#include <algorithm>
#include <fstream>
#include <numeric>

namespace agi {

std::map<std::string, Timer::TimerRecord> Timer::records_;

void Timer::PrintAll() {
    LOG(INFO) << ">>> ===== Printing run time =====";
    for (auto& r : records_) {
        auto& rec = r.second.time_usage_in_ms_;
        std::sort(rec.begin(), rec.end());
        LOG(INFO) << "> [ " << r.first
                  << " ] average time usage: " << std::accumulate(rec.begin(), rec.end(), 0.0) / double(rec.size())
                  << " ms , med: " << rec[rec.size() * 0.5] << ", 95%: " << rec[rec.size() * 0.95]
                  << ", called times : " << r.second.time_usage_in_ms_.size();
    }
    LOG(INFO) << ">>> ===== Printing run time end =====";
}

void Timer::DumpIntoFile(const std::string& file_name) {
    std::ofstream ofs(file_name, std::ios::out);
    if (!ofs.is_open()) {
        LOG(ERROR) << "Failed to open file: " << file_name;
        return;
    } else {
        LOG(INFO) << "Dump Time Records into file: " << file_name;
    }

    size_t max_length = 0;
    for (const auto& iter : records_) {
        ofs << iter.first << ", ";
        if (iter.second.time_usage_in_ms_.size() > max_length) {
            max_length = iter.second.time_usage_in_ms_.size();
        }
    }
    ofs << std::endl;

    for (size_t i = 0; i < max_length; ++i) {
        for (const auto& iter : records_) {
            if (i < iter.second.time_usage_in_ms_.size()) {
                ofs << iter.second.time_usage_in_ms_[i] << ",";
            } else {
                ofs << ",";
            }
        }
        ofs << std::endl;
    }
    ofs.close();
}

double Timer::GetMeanTime(const std::string& func_name) {
    if (records_.find(func_name) == records_.end()) {
        return 0.0;
    }

    auto r = records_[func_name];
    return std::accumulate(r.time_usage_in_ms_.begin(), r.time_usage_in_ms_.end(), 0.0) /
           double(r.time_usage_in_ms_.size());
}
}  // namespace agi