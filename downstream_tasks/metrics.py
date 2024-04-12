# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the Apache License, Version 2.0
# found in the LICENSE file in the root directory of this source tree.

from enum import Enum
import logging
from typing import Any, Dict, Optional

import torch
from torch import Tensor
from torchmetrics import Metric, MetricCollection
from torchmetrics.wrappers.bootstrapping import BootStrapper
from torchmetrics.classification import MulticlassAccuracy, auroc
from torchmetrics.classification.f_beta import F1Score
from torchmetrics import AUROC


logger = logging.getLogger("dinov2")


def build_metric(metric_type, num_classes):
    if metric_type == 'knn':
        return build_knn_metric(num_classes=num_classes)
    elif metric_type == 'linear':
        return build_linear_metric(num_classes=num_classes)

    raise ValueError(f"Unknown metric type {metric_type}")


def build_knn_metric(num_classes):
    metrics: Dict[str, Metric] = {
        "top1 acc": MulticlassAccuracy(top_k=1, num_classes=int(num_classes), average='weighted'),
        "f1_score": F1Score(num_classes=int(num_classes), average='weighted', task='multiclass'),
    }
    # boot strap wrap 
    for k, m in metrics.items():
        print('wrapping:', k)
        metrics[k] = BootStrapper(m, num_bootstraps=50)

    metrics = MetricCollection(metrics)
    return metrics

def build_linear_metric(num_classes, bootstrap=False):
    metrics: Dict[str, Metric] = {
        "top1 acc": MulticlassAccuracy(top_k=1, num_classes=int(num_classes), average='weighted'),
        "f1_score": F1Score(num_classes=int(num_classes), average='weighted', task='multiclass'),
        "AUC": AUROC(num_classes=num_classes, average='weighted', task='multiclass')
    }
    # boot strap wrap 
    if bootstrap:
        for k, m in metrics.items():
            print('wrapping:', k)
            metrics[k] = BootStrapper(m, num_bootstraps=50)

    metrics = MetricCollection(metrics)
    return metrics